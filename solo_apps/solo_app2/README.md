Solo App 2 is a simple implementation of a BMI calculator. It is contained completely in the 
main.dart file and can be run from this file. It includes input validation for the height and weight 
text fields. Additionally, simple state management is seen by tapping anywhere on the screen that is 
not a textfield or button to change the background color. The text color will change 
accordingly with the background color for readability and overall polish.

Color Palette <background color, text color>:
[
 (lightBlue[100], black), 
 (red[300], black), 
 (yellow[200], black), 
 (deepPurple, white), 
 (green[900], white)
]


Sample Inputs & Test Cases:
1. (Pass Case)       
   height = 70
   weight = 170
   expected BMI = 24.39
2. (Pass Case 2)
   height = 63
   weight = 215
   expected BMI = 38.08
3. (Fail Case 1)
   height = invalid
   weight = invalid
   expected BMI = n/a
   error message should be shown
4. (fail Case 2)
   height = 70
   weight = 170xx
   expected BMI = n/a
   error message should be shown
5. (background color test)
   click on any open space as many times as you please