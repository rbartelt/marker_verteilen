import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geodesy/geodesy.dart';
import 'package:marker_verteilen/domain/services/beachsection_service.dart';
import 'package:marker_verteilen/presentation/widgets/side_menu.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/beachsection.dart';
import '../bloc/beachsection_bloc.dart';

class BeachSectionScreen extends StatefulWidget {
  const BeachSectionScreen({super.key});

  @override
  BeachSectionScreenState createState() => BeachSectionScreenState();
}

class BeachSectionScreenState extends State<BeachSectionScreen> {
  List<BeachSection> beachSections = [];
  bool _isAddingBeachSection = false;
  String _infoMessage = '';
  bool _showInputForm = false;
  int _numRows = 3;
  double _spotSpacing = 4.0;
  double _rowSpacing = 4.0;
  LatLng? _startPoint;
  LatLng? _endPoint;
  List<LatLng> _spots = [];
  BeachSection? _selectedBeachSection;
  bool _markersDisplayed = false;

  String _numRowsErrorMessage = '';
  String _spotSpacingErrorMessage = '';
  String _rowSpacingErrorMessage = '';

  final FocusNode _numRowsFocusNode = FocusNode();
  final FocusNode _spotSpacingFocusNode = FocusNode();
  final FocusNode _rowSpacingFocusNode = FocusNode();

  final TextEditingController _numRowsController = TextEditingController();
  final TextEditingController _spotSpacingController = TextEditingController();
  final TextEditingController _rowSpacingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _numRowsController.text = _numRows.toString();
    _spotSpacingController.text = _spotSpacing.toString();
    _rowSpacingController.text = _rowSpacing.toString();

    _numRowsFocusNode.addListener(() => _validateInput(_numRowsFocusNode, _validateNumRows));
    _spotSpacingFocusNode.addListener(() => _validateInput(_spotSpacingFocusNode, _validateSpotSpacing));
    _rowSpacingFocusNode.addListener(() => _validateInput(_rowSpacingFocusNode, _validateRowSpacing));
  }

  @override
  void dispose() {
    _numRowsFocusNode.dispose();
    _spotSpacingFocusNode.dispose();
    _rowSpacingFocusNode.dispose();
    _numRowsController.dispose();
    _spotSpacingController.dispose();
    _rowSpacingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Beachmap'),
      ),
      body: Row(
        children: [
          const SideMenu(),
          Expanded(
            child: BlocBuilder<BeachSectionBloc, BeachSectionState>(
              builder: (context, state) {
                if (state is BeachSectionInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BeachSectionAdded || state is BeachSectionUpdated || state is BeachSectionDeleted) {
                  if (state is BeachSectionAdded) {
                    beachSections = state.beachSections;
                  } else if (state is BeachSectionUpdated) {
                    beachSections = state.beachSections;
                  } else if (state is BeachSectionDeleted) {
                    beachSections = state.beachSections;
                  }
                  return Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(54.01758319961416, 14.069338276999131),
                          initialZoom: 19,
                          initialRotation: -45,
                          onTap: (tapPosition, point) => _handleTap(point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                            subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                            userAgentPackageName: 'com.example.app',
                            tileProvider: CancellableNetworkTileProvider(),
                          ),
                          MarkerLayer(
                            markers: _buildMarkers(),
                          ),
                        ],
                      ),
                      _buildTopRightButton(),
                      if (_infoMessage.isNotEmpty) _buildInfoMessage(),
                      if (_showInputForm) _buildInputForm(context),
                    ],
                  );
                } else {
                  return const Center(child: Text('Unexpected state'));
                }
              },
            ),
          )
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Füge Marker für alle BeachSections hinzu
    for (var section in beachSections) {
      markers.addAll(section.spots.map(
        (spot) => Marker(
          width: 80.0,
          height: 80.0,
          point: spot,
          child: GestureDetector(
            onTap: () => _selectBeachSection(section),
            child: Icon(
              Icons.location_on,
              color: _selectedBeachSection == section ? Colors.green : Colors.blue,
            ),
          ),
        ),
      ));
    }

    // Füge Start- und Endpunkt-Marker für den aktuell bearbeiteten Abschnitt hinzu
    if (_startPoint != null) {
      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: _startPoint!,
        child: const Icon(Icons.location_on, color: Colors.red),
      ));
    }
    if (_endPoint != null) {
      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: _endPoint!,
        child: const Icon(Icons.location_on, color: Colors.red),
      ));
    }

    // Füge temporäre Marker für die aktuell bearbeitete oder neue BeachSection hinzu
    if (_markersDisplayed) {
      markers.addAll(_spots.map(
        (spot) => Marker(
          width: 80.0,
          height: 80.0,
          point: spot,
          child: const Icon(Icons.location_on, color: Colors.orange),
        ),
      ));
    }

    return markers;
  }

  Positioned _buildTopRightButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        color: Colors.white.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _startAddingBeachSection,
              child: const Text('Add Beach Section'),
            ),
          ],
        ),
      ),
    );
  }

  Positioned _buildInfoMessage() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blue,
        child: Text(
          _infoMessage,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Positioned _buildInputForm(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: FocusTraversalGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_selectedBeachSection == null ? 'Add Beach Section' : 'Edit Beach Section', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              FocusTraversalOrder(
                order: const NumericFocusOrder(1),
                child: _buildTextField('Number of Rows', _numRowsController, _numRowsFocusNode, _numRowsErrorMessage),
              ),
              const SizedBox(height: 8),
              FocusTraversalOrder(
                order: const NumericFocusOrder(2),
                child: _buildTextField('Space between beachchairs (m)', _spotSpacingController, _spotSpacingFocusNode, _spotSpacingErrorMessage),
              ),
              const SizedBox(height: 8),
              FocusTraversalOrder(
                order: const NumericFocusOrder(3),
                child: _buildTextField('Space between rows (m)', _rowSpacingController, _rowSpacingFocusNode, _rowSpacingErrorMessage),
              ),
              const SizedBox(height: 16),
              if (_selectedBeachSection != null)
                ElevatedButton(
                  onPressed: _deleteSelectedBeachSection,
                  child: const Text('Delete'),
                ),
              ElevatedButton(
                onPressed: _cancelEdit,
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _markersDisplayed ? _saveBeachSection : null,
                child: Text(_selectedBeachSection == null ? 'Save Beach Section' : 'Update Beach Section'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(String labelText, TextEditingController controller, FocusNode focusNode, String errorMessage) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '1 - 20',
        labelText: labelText,
        errorText: errorMessage.isNotEmpty ? errorMessage : null,
      ),
      controller: controller,
      focusNode: focusNode,
      onEditingComplete: () {
        if (labelText == 'Number of Rows') {
          _validateNumRows();
        } else if (labelText == 'Space between beachchairs (m)') {
          _validateSpotSpacing();
        } else if (labelText == 'Space between rows (m)') {
          _validateRowSpacing();
        }
        _validateAndDisplayMarkers();
        FocusScope.of(context).nextFocus(); // Bewegt den Fokus zum nächsten Feld
      },
    );
  }

  void _setInitialFocus() {
    if (_showInputForm) {
      _numRowsFocusNode.requestFocus();
    }
  }

  void _startAddingBeachSection() {
    _cancelEdit(); // Verwendet die neue _cancelEdit Methode zum Zurücksetzen
    setState(() {
      _isAddingBeachSection = true;
      _infoMessage = 'Klicke den ersten Punkt des Strandabschnittes an.';
    });
  }

  void _validateAndDisplayMarkers() {
    _validateNumRows();
    _validateSpotSpacing();
    _validateRowSpacing();

    if (_numRowsErrorMessage.isEmpty && _spotSpacingErrorMessage.isEmpty && _rowSpacingErrorMessage.isEmpty && _startPoint != null && _endPoint != null) {
      setState(() {
        _spots = BeachSectionService().distributeSpotsForBeachSection(_startPoint!, _endPoint!, _numRows, _rowSpacing, _spotSpacing);
        _markersDisplayed = true;
      });
    } else {
      setState(() {
        _infoMessage = 'Please fill in all fields correctly and select start and end points.';
        _markersDisplayed = false;
      });
    }
  }

  void _saveBeachSection() {
    if (_markersDisplayed && _spots.isNotEmpty) {
      if (_selectedBeachSection == null) {
        // Neue BeachSection hinzufügen
        BeachSection newSection = BeachSection(
          id: const Uuid().v4(),
          startPoint: _startPoint!,
          endPoint: _endPoint!,
          numRows: _numRows,
          rowSpacing: _rowSpacing,
          spotSpacing: _spotSpacing,
          spots: _spots,
        );
        BlocProvider.of<BeachSectionBloc>(context).add(AddBeachSectionEvent(newSection));
      } else {
        // Bestehende BeachSection aktualisieren
        BeachSection updatedSection = BeachSection(
          id: _selectedBeachSection!.id,
          startPoint: _startPoint!,
          endPoint: _endPoint!,
          numRows: _numRows,
          rowSpacing: _rowSpacing,
          spotSpacing: _spotSpacing,
          spots: _spots,
        );
        BlocProvider.of<BeachSectionBloc>(context).add(UpdateBeachSectionEvent(updatedSection));
      }

      setState(() {
        _isAddingBeachSection = false;
        _showInputForm = false;
        _infoMessage = '';
        _startPoint = null;
        _endPoint = null;
        _spots = [];
        _markersDisplayed = false;
        _selectedBeachSection = null;
      });
    } else {
      setState(() {
        _infoMessage = 'Please display markers first.';
      });
    }
  }

  void _selectBeachSection(BeachSection section) {
    setState(() {
      _selectedBeachSection = section;
      _numRows = section.numRows;
      _spotSpacing = section.spotSpacing;
      _rowSpacing = section.rowSpacing;
      _startPoint = section.startPoint;
      _endPoint = section.endPoint;
      _numRowsController.text = _numRows.toString();
      _spotSpacingController.text = _spotSpacing.toString();
      _rowSpacingController.text = _rowSpacing.toString();
      _showInputForm = true;
    });
    _setInitialFocus();
  }

  void _deleteSelectedBeachSection() {
    if (_selectedBeachSection != null) {
      BlocProvider.of<BeachSectionBloc>(context).add(DeleteBeachSectionEvent(_selectedBeachSection!));
      _cancelEdit();
    }
  }

  void _cancelEdit() {
    setState(() {
      _selectedBeachSection = null;
      _showInputForm = false;
      _isAddingBeachSection = false;
      _startPoint = null;
      _endPoint = null;
      _spots = [];
      _markersDisplayed = false;
      _infoMessage = '';

      // Zurücksetzen der Eingabefelder auf Standardwerte
      _numRows = 3;
      _spotSpacing = 4.0;
      _rowSpacing = 4.0;
      _numRowsController.text = _numRows.toString();
      _spotSpacingController.text = _spotSpacing.toString();
      _rowSpacingController.text = _rowSpacing.toString();

      // Zurücksetzen der Fehlermeldungen
      _numRowsErrorMessage = '';
      _spotSpacingErrorMessage = '';
      _rowSpacingErrorMessage = '';
    });
  }

  void _handleTap(LatLng point) {
    if (!_isAddingBeachSection && _selectedBeachSection == null) return;

    setState(() {
      if (_startPoint == null) {
        _startPoint = point;
        _infoMessage = 'Klicke nun den zweiten Punkt des Strandabschnittes an.';
      } else if (_endPoint == null) {
        _endPoint = point;
        _infoMessage = 'Bitte füllen Sie alle Eingabefelder aus und speichern den Strandabschnitt.';
        _showInputForm = true;
      }
    });
    if (_showInputForm) {
      _setInitialFocus();
    }
  }

  void _validateInput(FocusNode focusNode, Function validateFunction) {
    if (!focusNode.hasFocus) {
      validateFunction();
      if (_numRowsErrorMessage.isEmpty && _spotSpacingErrorMessage.isEmpty && _rowSpacingErrorMessage.isEmpty) {
        _validateAndDisplayMarkers();
      }
    }
  }

  void _validateNumRows() {
    setState(() {
      _numRowsErrorMessage = '';
      final parsedValue = int.tryParse(_numRowsController.text);
      if (parsedValue == null || parsedValue < 1 || parsedValue > 20) {
        _numRowsErrorMessage = 'Bitte geben Sie eine Zahl zwischen 1 und 20 ein.';
      } else {
        _numRows = parsedValue;
      }
    });
  }

  void _validateSpotSpacing() {
    setState(() {
      _spotSpacingErrorMessage = '';
      final parsedValue = double.tryParse(_spotSpacingController.text);
      if (parsedValue == null || parsedValue <= 0) {
        _spotSpacingErrorMessage = 'Bitte geben Sie eine gültige Zahl ein.';
      } else {
        _spotSpacing = parsedValue;
      }
    });
  }

  void _validateRowSpacing() {
    setState(() {
      _rowSpacingErrorMessage = '';
      final parsedValue = double.tryParse(_rowSpacingController.text);
      if (parsedValue == null || parsedValue <= 0) {
        _rowSpacingErrorMessage = 'Bitte geben Sie eine gültige Zahl ein.';
      } else {
        _rowSpacing = parsedValue;
      }
    });
  }
}
