import 'package:flutter/material.dart';

class BeautifulDivider extends StatelessWidget {
  final bool dType;
  const BeautifulDivider(this.dType, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Expanded(
            child: Divider(
              color: Colors.white, // Change color as desired
              height: 50, // Adjust height as needed
              thickness: 2, // Adjust thickness as needed
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Text(dType ?
              '┏━•❃°•°❀°•°❃•━┓' : '╚═*.·:·.✧ ✦ ✧.·:·.*═╝', // Text to separate or decorate
              style: const TextStyle(
                color: Colors.white, // Change text color as needed
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: Colors.white, // Change color as desired
              height: 50, // Adjust height as needed
              thickness: 2, // Adjust thickness as needed
            ),
          ),
        ],
      ),
    );
  }
}

// Example usage:
// Simply use BeautifulDivider() wherever you want a beautiful divider.