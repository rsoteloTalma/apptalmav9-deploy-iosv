import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  final int taskId;
  final bool directCapture;
  final void Function(String)? onSave; // callback hacia el padre

  const QrScannerPage({
    super.key,
    required this.taskId,
    required this.directCapture,
    this.onSave,
  });

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final TextEditingController qrTextController = TextEditingController();
  bool _isProcessing = false;
  bool _isEditable = false;

  @override
  void dispose() {
    controller.dispose();
    qrTextController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    _isProcessing = true;

    if (capture.barcodes.isNotEmpty) {
      final Barcode barcode = capture.barcodes.first;
      final String? rawValue = barcode.rawValue;

      if (rawValue != null && rawValue.isNotEmpty) {
        debugPrint('QR detectado: $rawValue');

        // actualizar el textfield
        setState(() {
          qrTextController.text = rawValue;
        });

        if (widget.directCapture) {
          Navigator.pop(context, rawValue); // captura directa
        } else {
          _isProcessing = false; // seguir leyendo
        }
      } else {
        _isProcessing = false;
      }
    } else {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth >= 600;
    final scanner = MobileScanner(
      controller: controller,
      onDetect: _onDetect,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Escanear QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => controller.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: widget.directCapture
          ? scanner
          : Column(
              children: [
                Expanded(
                  flex: 8,
                  child: Center(
                    child: Container(
                      width: !isTablet ? 300 : 500,
                      height: !isTablet ? 300 : 500,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.primaryColor, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: scanner,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: SizedBox(
                        width: !isTablet ? 300 : 500,
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: qrTextController,
                          builder: (context, value, child) {
                            final hasValue = value.text.trim().isNotEmpty;
                            final highlightColor =
                                Colors.green; // Color para resaltar

                            return TextField(
                              controller: qrTextController,
                              readOnly: !_isEditable,
                              style: TextStyle(
                                fontWeight: hasValue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: hasValue ? highlightColor : null,
                              ),
                              decoration: InputDecoration(
                                labelText: "ID Escaneado",
                                filled: hasValue,
                                fillColor: hasValue
                                    ? highlightColor.withOpacity(0.1)
                                    : null,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        hasValue ? highlightColor : Colors.grey,
                                    width: hasValue ? 2.0 : 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        hasValue ? highlightColor : Colors.grey,
                                    width: hasValue ? 2.0 : 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: hasValue
                                        ? highlightColor
                                        : Theme.of(context).primaryColor,
                                    width: 2.0,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.qr_code,
                                  color: hasValue ? highlightColor : null,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isEditable ? Icons.lock_open : Icons.edit,
                                    color: hasValue ? highlightColor : null,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isEditable = !_isEditable;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final value = qrTextController.text.trim();
                        if (value.isNotEmpty) {
                          widget.onSave?.call(value);
                          Navigator.pop(context, value);
                        }
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.grey,
                      ),
                      label: const Text("GUARDAR"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
