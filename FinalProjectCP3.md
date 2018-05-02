Check Point 3 Individual Projects
Programing Project Workshop
CSCI 3010
Spring 2018 5/2
Joshua Griffiths

1)Planned: "Check Point 1 Individual Projects
Programing Project Workshop
CSCI 3010
Spring 2018 4/4
Joshua Griffiths

1)Planned: "Fix Bugs, admendments: going to use copyright graphics until I learn photoshop, going to forgo leaderboard due to time constraints"

2)Acomplished: All of the above and more (Factory design patern, testing). The game is entirly complete and playable and has all the features described in the project proposal with the exception of a leaderboard. Reason: Taking the time to learn how to save a state (highscore for players) in between compilations (ie over multiples compilations) is not possible on the count of its due tonight. Also all the graphics are all copyrighted aka stollen (I didnt make them myself) but I gave credit to the makers in my code. There are a few small and rare bugs left that I describe bellow. 

3)Planned for next time: All the rest of these tasks are purely astetic and dont add to the gameplay itself or acomplish 
//5) Move Score Singelton in to player class
//6) Get rid of use of dificulty.numTowers and use local variables
//8) Make Bacground and tilemap move with towers so it looks like everything is moving
//9) Use better programing grammar(move bucket spawn in to bucket class)
//10) Make my own graphics
//11) Make explosion animations on impacts

TESTING: All testing was done through XCodes Performance Testing suit. The main outcome of this testing was adjusting the update() function. The update() function is called every frame. The conclusion was the less if statements and for loops in the update function the higher the frame rate would be and smoother the gameplay would look. Measures were taken to remove conditional statments and for loops out of the update functions and place that same functionality else where. As you can see from the results even in worst case scenrio (During 10+ minicube spawn after Tower Hit, Towers are in motion) the Frame Rate only drops by 2 frames per second. Before testing and with aditional componetns (mostly for loops) in the update function we had a frame rate drop of 5 in a worst case scneario. A few screenshots of this process were added in to the repository. The results of the tests were as follows:

During No GamePlay action: FPS: 12 fps (We strive to get as close to this as possible in all other gameplay actions)

During Toss No Tower Hit: 11.6 fps

Durring Towers in motion 3 or less minicube spawns:  11.4 fps

During 10+ minicube spawn after Tower Hit, Towers are in motion: 10 fps


During Closing Screen: 12 fps

In Main Menu: 12 fps



BUGS:

//1) Bug: minicube can hit player =>may be fixed by playing on iphone or next bug fix
//2) Bug (Rare): Infinite minicube spawn=> fixed by Reduce the number of cubes that can spwan on each consecutive minicube towertop hit (reset it when player is tossed again
//3) Bug: Tile hits arent always detected => fixed with new smaller tile graphics



SECURITY: For security I chose to implement a cheeky workaround that encrypts user data and stores it perrsistantly across application launches. I do this by storing the higscore data as a UserData class. The UserData class encrypts the highscore so it cant be accessed unless specified by the application. Although it is just stack overflow I am taking this guys word for it and everything I read on the Swifts documentation verifies what he is saying in more words. https://stackoverflow.com/questions/28306517/secure-way-of-storing-a-highscore-in-ios-game 


4)Screenshots of Testing and one new Screenshot showing Updated Game Scene In repository. 


