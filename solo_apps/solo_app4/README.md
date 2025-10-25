
https://github.com/noahrcarter/CPSC-6150/new/main/solo_apps/solo_app4

Solo App 4 is a clicker game that uses shared_preferences to store the high score and the history of scores over time. This data persists across app restarts, 
but there is a reset button for testing and proof of functionality to reset the necessary values. Running requires only the main.dart and pubspec.yaml included
in this repo. Note, however, that shared_preferences requires NDK 27 and any flutter package or build.gradle.kts should be adapted to this requirment. When testing, 
there is little in the realm of edge cases, but the 'high score achieved' dialogue box may be tested by achieving a high score and continuing to ensure it does not 
reappear or ensuring that the 'High Score' field reflects the correct value. Likewise, the 'Score' field should increment by one each time and should properly reflect 
the number of clicks for that game.


Demo: https://www.loom.com/share/a046665fb66e47f8b2fb195fab3dfc10
