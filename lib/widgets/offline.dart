import 'package:flutter/material.dart';

 Widget offlineMessageCard(BuildContext context, String message) {
    return Center(
        child: Card(
          margin: EdgeInsets.only(top: 20),
          elevation: 0,
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 2.0,
              )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.red,
                  fontSize: 18,
                )
              ),
            ),
          ),
        ),
    );
  }





