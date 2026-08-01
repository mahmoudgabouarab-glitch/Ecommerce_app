import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'widgets/about/about_body.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('about'.tr())),
      body: const SafeArea(child: AboutBody()),
    );
  }
}
