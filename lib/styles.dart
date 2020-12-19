import 'package:flutter/material.dart';

class MSPTTheme {
  MSPTTheme._();

  // Default Base Themes to Manipulate
  static final ThemeData baseLight = ThemeData.light();
  static final ThemeData baseDark = ThemeData.dark();

  // Base Text Theme Style
  static TextTheme baseTextTheme(TextTheme defaultBase){
    return defaultBase.copyWith(
      
      headline1: defaultBase.headline1.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
      headline2: defaultBase.headline1.copyWith(
        fontSize: 20,
        color: Colors.black87,
        fontWeight: FontWeight.w700,
      ),
      headline3: defaultBase.headline1.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      headline4: defaultBase.headline1.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      headline5: defaultBase.headline1.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      headline6: defaultBase.headline1.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w300,
      ),
      subtitle1: defaultBase.headline1.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w300,
      ),
      subtitle2: defaultBase.headline1.copyWith(
        fontSize: 14,
        color: Colors.grey,
        fontWeight: FontWeight.w300,
      ),
      bodyText1: defaultBase.headline1.copyWith(
        color: Colors.grey,
        fontSize: 16,
      ),
      bodyText2: defaultBase.headline1.copyWith(
        color: Colors.grey.withOpacity(0.9),
        fontSize: 14,
      ),
      
    );
  }

  // Light Theme
  static final ThemeData lightTheme = baseLight.copyWith(
    primaryColor: Color(0xFF023047), // 
    scaffoldBackgroundColor: Color(0xFFE5E5E5),
    brightness: Brightness.light,
    accentColor: Color(0xA6023047),
    textTheme: baseTextTheme(baseLight.textTheme),
  );

  // Needs Sprucing Up: Not in use for now
  // Dark Theme: Mostly Manipulate Light Theme Colors
  static final ThemeData darkTheme = baseDark.copyWith(
    textTheme: baseTextTheme(lightTheme.textTheme).copyWith(
      headline1: lightTheme.textTheme.headline1.copyWith(color: Colors.white),
      headline2: lightTheme.textTheme.headline2.copyWith(color: Colors.white),
      headline3: lightTheme.textTheme.headline3.copyWith(color: Colors.white70),
      headline4: lightTheme.textTheme.headline4.copyWith(color: Colors.white60),
      headline5: lightTheme.textTheme.headline5.copyWith(color: Colors.white54),
      headline6: lightTheme.textTheme.headline6.copyWith(color: Colors.white38),
      subtitle1: lightTheme.textTheme.subtitle1.copyWith(color: Colors.white54),
      subtitle2: lightTheme.textTheme.subtitle2.copyWith(color: Colors.white38),
      bodyText1: lightTheme.textTheme.bodyText1.copyWith(color: Colors.white70),
      bodyText2: lightTheme.textTheme.bodyText2.copyWith(color: Colors.white60),
    ),
  );
}
