import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import '../../components/background.dart';
import '../../constants.dart';
import '../../responsive.dart';
import 'components/login_signup_btn.dart';
import 'components/welcome_image.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/rendering.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController summaryController = TextEditingController();

  final TextEditingController locationController = TextEditingController();
  DateTime startTime = DateTime.now();
  int reminderHours = 1;

  String? _qrCodeText;
  GlobalKey globalKey = GlobalKey();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        startTime = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startTime),
    );

    if (pickedTime != null) {
      DateTime pickedDateTime = DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        startTime = pickedDateTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: const MobileWelcomeScreen(),
          desktop: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: _welcomeImage(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding * 5),
                    child: Column(
                      children: [
                        Text(
                            'Fill in the details related to your wedding below',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold)),
                        const SizedBox(height: defaultPadding * 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            controller: summaryController,
                            cursorColor: kPrimaryColor,
                            onSaved: (summary) {},
                            decoration: const InputDecoration(
                              hintText: "Title",
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(defaultPadding),
                                child: Icon(Icons.event),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            controller: locationController,
                            cursorColor: kPrimaryColor,
                            onSaved: (location) {},
                            decoration: const InputDecoration(
                              hintText: "Location",
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(defaultPadding),
                                child: Icon(Icons.location_on),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: const Text('Day',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor)),
                                subtitle: Text(
                                  DateFormat('dd:MM:yyyy')
                                      .format(startTime.toLocal()),
                                ),
                                onTap: () => _selectDate(context),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: const Text(
                                  'Time',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor),
                                ),
                                subtitle: Text(DateFormat('HH:mm')
                                    .format(startTime.toLocal())),
                                onTap: () => _selectTime(context),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                ),
                                const Text(
                                  'Reminder',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 4),
                                // Add spacing between text and DropdownButton
                                DropdownButton<int>(
                                  value: reminderHours,
                                  icon: const SizedBox(),
                                  underline: const SizedBox(),
                                  items: [1, 2, 3, 4, 5, 12, 24, 36, 48]
                                      .map((hour) => DropdownMenuItem<int>(
                                            value: hour,
                                            child: Text(
                                              '$hour hour(s)',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: kPrimaryColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      reminderHours = value;
                                    });
                                  },
                                ),
                                const Text(
                                  'before',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime endTime =
                                  startTime.add(const Duration(hours: 2));
                              String eventText = '''
BEGIN:VEVENT
SUMMARY:${summaryController.text}
LOCATION:${locationController.text}
DTSTART:${DateFormat('yyyyMMddTHHmmss').format(startTime.toUtc())}
DTEND:${DateFormat('yyyyMMddTHHmmss').format(endTime.toUtc())}
BEGIN:VALARM
TRIGGER:-PT${reminderHours}H
DESCRIPTION:Reminder
ACTION:DISPLAY
END:VALARM
END:VEVENT
''';

                              print('eventText: $eventText');
                              _generateQRCode(eventText);
                            },
                            child: const Text('Generate QR Code'),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _generateQRCode(String eventText) {
    setState(() {
      _qrCodeText = eventText;
    });
  }

  Widget _welcomeImage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/icons/favicon.png',
                    height: 60,
                  ),
                  Text('Quetdi.com',
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              )),
                ],
              ),
              const SizedBox(height: defaultPadding / 2),
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  'Where the vibrant hues of life begin – A unique connectivity platform where every detail of the wedding becomes exquisite, and the realm of joy is \'scanned away\' with care and precision',
                  style: TextStyle(
                      height: 2,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: defaultPadding * 2),
        SizedBox(
          height: 400,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              if (_qrCodeText == null)
                Expanded(
                    flex: 8,
                    child: SvgPicture.asset(
                      "assets/icons/chat.svg",
                    ))
              else
                Column(
                  children: [
                    WidgetsToImage(
                      controller: controller,
                      child: QrImageView(
                        key: globalKey,
                        data: _qrCodeText!,
                        version: QrVersions.auto,
                        size: 300.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _downloadImage();
                      },
                      child: const Text(
                        'Download QR Code',
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  ],
                ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }

  Future<void> _downloadImage() async {
    final bytes = await controller.capture();
    final name =
        'qrcode-${(summaryController.text.isNotEmpty == true ? summaryController.text : 'Qrcode')}.png';
    await WebImageDownloader.downloadImageFromUInt8List(
        uInt8List: bytes!, name: name);
  }

  WidgetsToImageController controller = WidgetsToImageController();
}

class MobileWelcomeScreen extends StatefulWidget {
  const MobileWelcomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MobileWelcomeScreen> createState() => _MobileWelcomeScreenState();
}

class _MobileWelcomeScreenState extends State<MobileWelcomeScreen> {
  final TextEditingController summaryController = TextEditingController();
  WidgetsToImageController controller = WidgetsToImageController();

  final TextEditingController locationController = TextEditingController();
  DateTime startTime = DateTime.now();
  int reminderHours = 1;

  String? _qrCodeText;
  GlobalKey globalKey = GlobalKey();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        startTime = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startTime),
    );

    if (pickedTime != null) {
      DateTime pickedDateTime = DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        startTime = pickedDateTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding * 2, vertical: defaultPadding),
          child: Column(
            children: [
              Image.asset(
                'assets/icons/favicon.png',
                height: 60,
              ),
              Text('Quetdi.com',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      )),
              const Text(
                'Where the vibrant hues of life begin – A unique connectivity platform where every detail of the wedding becomes exquisite, and the realm of joy is \'scanned away\' with care and precision',
                textAlign: TextAlign.center,
                style: TextStyle(
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.black45),
              ),
              const Divider(),
              const SizedBox(height: defaultPadding * 2),
              Text('Fill in the details related to your wedding below',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      color: Colors.redAccent.withOpacity(0.8),
                      fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  controller: summaryController,
                  cursorColor: kPrimaryColor,
                  onSaved: (summary) {},
                  decoration: const InputDecoration(
                    hintText: "Title",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.event),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  controller: locationController,
                  cursorColor: kPrimaryColor,
                  onSaved: (location) {},
                  decoration: const InputDecoration(
                    hintText: "Location",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.location_on),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Day',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor)),
                      subtitle: Text(
                        DateFormat('dd:MM:yyyy').format(startTime.toLocal()),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Time',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                      ),
                      subtitle:
                          Text(DateFormat('HH:mm').format(startTime.toLocal())),
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                      ),
                      const Text(
                        'Reminder',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      // Add spacing between text and DropdownButton
                      DropdownButton<int>(
                        value: reminderHours,
                        icon: const SizedBox(),
                        underline: const SizedBox(),
                        items: [1, 2, 3, 4, 5, 12, 24, 36, 48]
                            .map((hour) => DropdownMenuItem<int>(
                                  value: hour,
                                  child: Text(
                                    '$hour hour(s)',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            reminderHours = value;
                          });
                        },
                      ),
                      const Text(
                        'before',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    DateTime endTime = startTime.add(const Duration(hours: 2));
                    String eventText = '''
BEGIN:VEVENT
SUMMARY:${summaryController.text}
LOCATION:${locationController.text}
DTSTART:${DateFormat('yyyyMMddTHHmmss').format(startTime.toLocal())}
DTEND:${DateFormat('yyyyMMddTHHmmss').format(endTime.toLocal())}
BEGIN:VALARM
TRIGGER:-PT${reminderHours}H
DESCRIPTION:Reminder
ACTION:DISPLAY
END:VALARM
END:VEVENT
''';

                    print('eventText: $eventText');
                    _generateQRCode(eventText);
                  },
                  child: const Text('Generate QR Code'),
                ),
              ),
              const SizedBox(height: defaultPadding),
              if (_qrCodeText != null)
                Column(
                  children: [
                    WidgetsToImage(
                      controller: controller,
                      child: QrImageView(
                        key: globalKey,
                        data: _qrCodeText!,
                        version: QrVersions.auto,
                        size: 300.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _downloadImage();
                      },
                      child: const Text(
                        'Download QR Code',
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadImage() async {
    final bytes = await controller.capture();
    final name =
        'qrcode-${(summaryController.text.isNotEmpty == true ? summaryController.text : 'Qrcode')}.png';
    await WebImageDownloader.downloadImageFromUInt8List(
        uInt8List: bytes!, name: name);
  }

  void _generateQRCode(String eventText) {
    setState(() {
      _qrCodeText = eventText;
    });
  }
}
