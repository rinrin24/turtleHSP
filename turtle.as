#include "hspmath.as"

#define true 1
#define false 0

#define red $ff0000
#define green $00ff00
#define blue $0000ff
#define black $000000
#define white $ffffff

#define fastest 0
#define fast 10
#define normal 6
#define slow 3
#define slowest 1

#const DEFAULT_WAIT 20
#const DEFAULT_TURTLE_SPEED 3
#const TURTLE_PICTURE_SIZEX 50
#const TURTLE_PICTURE_SIZEY 50
#const BUFFER_WINDOWID 1
#const TURTLE_PICTURE_WINDOWID 2
#const ROTATE_MIN_UNIT 1	//degree

#undef goto

/*ƒ[ƒJƒ‹•Ï”
turtlePositionX: ‹T‚ÌXÀ•W
turtlePositionY: ‹T‚ÌYÀ•W
turtleHeading: ‹T‚ÌŒü‚¢‚Ä‚¢‚é•û–@(“x)(“Œ‚ª0‹‚Å”½ŽžŒv‰ñ‚è‚É)
turtleSpeed: ‹T‚ÌˆÚ“®‘¬“x
penIsDown: ƒyƒ“‚ª~‚è‚Ä‚ê‚Îtrue, ƒyƒ“‚ªã‚ª‚Á‚Ä‚¢‚ê‚Îfalse
turtleIsVisible: ‹T‚ª‰ÂŽ‹‚©
penColorCode: pen‚Ì•`‰æF(16iRGB)
backgroundColor: ”wŒiF

mainScreen: •`‰ææƒEƒBƒ“ƒhƒE‚ÌƒEƒBƒ“ƒhƒEID

buffer 1: ‹TˆÈŠO‚Ì•`‰æ
*/

#module turtle
#deffunc local _drawAll
	rgbcolor bgcolor : boxf
	_drawShape@turtle
	_drawTurtle@turtle
	return
#deffunc local _drawShape
	gmode 0
	pos 0, 0
	gcopy 1, 0, 0, ginfo_winx, ginfo_winy
	return
#deffunc local _drawTurtle
	;logmes "drawwwww"
	if(turtleIsVisible == false@) : return
	;logmes int((turtlePositionX - TURTLE_PICTURE_SIZEX@ / 2) + ginfo_winx / 2)
	;logmes int((turtlePositionY - TURTLE_PICTURE_SIZEY@ / 2) + ginfo_winy / 2)
	;pos round@((turtlePositionX - TURTLE_PICTURE_SIZEX@ / 2) + ginfo_winx / 2), round@((turtlePositionY - TURTLE_PICTURE_SIZEY@ / 2) + ginfo_winy / 2)
	pos round@((turtlePositionX) + ginfo_winx / 2), round@((turtlePositionY) + ginfo_winy / 2)
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	rgbcolor green@
	gmode 4, pictureSizeX, pictureSizeY, 255
	grotate TURTLE_PICTURE_WINDOWID@, 0, 0, deg2rad(turtleHeading), TURTLE_PICTURE_SIZEX@, TURTLE_PICTURE_SIZEY@
	rgbcolor preColor
	return
#deffunc local _makeLine int x1_, int y1_, int x2_, int y2_
	if(penIsDown == false@) : return
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	gsel BUFFER_WINDOWID@, 1
	rgbcolor penColorCode

	line x1_ + ginfo_winx / 2, y1_ + ginfo_winy / 2, x2_ + ginfo_winx / 2, y2_ + ginfo_winy / 2
	logmes "(" + (x1_ + ginfo_winx / 2) + "," + (y1_ + ginfo_winy / 2) + "), (" + (x2_ + ginfo_winx / 2) + "," + (y2_ + ginfo_winy / 2)
	//logmes "x: " + turtlePositionX + "y: " + turtlePositionY
	logmes "x: " + int((turtlePositionX - TURTLE_PICTURE_SIZEX@ / 2) + ginfo_winx / 2) + ", y: " + int((turtlePositionY - TURTLE_PICTURE_SIZEY@ / 2) + ginfo_winy / 2)
	gsel mainScreen, 1
	rgbcolor preColor
	return
/**
@param ‰ñ“]‚·‚éŠp“x:double
@return void
*/
#deffunc local _rotateTurtle double angle_
	toAngle_ = turtleHeading + angle_
	moveFrequency = absf(angle_) / ROTATE_MIN_UNIT@
	if((moveFrequency \ 1) != 0) : moveFrequency++
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	repeat int(moveFrequency)
		redraw 0
		if(angle_ > 0){
			turtleHeading += ROTATE_MIN_UNIT@; * cnt
			if(turtleHeading > toAngle_) : turtleHeading = toAngle_
		}else{
			turtleHeading -= ROTATE_MIN_UNIT@; * cnt
			if(turtleHeading < toAngle_) : turtleHeading = toAngle_
		}
		_drawAll@turtle
		redraw 1
		;logmes cnt
		;logmes turtleHeading
		_waitTurtle@turtle
	loop
	rgbcolor preColor
	return
#deffunc local _waitTurtle
	if(turtleSpeed == false@) : return	//turtleSpeed‚ª0‚Ìê‡‚Íwait–³‚µ
	await DEFAULT_WAIT@ / turtleSpeed
	return
#deffunc local _moveToNewPosition double newPositionX_, double newPositionY_
	targetPositionX = round@(newPositionX_)
	targetPositionY = round@(newPositionY_)
	startPositionX = turtlePositionX
	startPositionY = turtlePositionY
	//logmes "tar: " + targetPositionX
	//logmes targetPositionY
	//logmes startPositionX
	//logmes startPositionY
	lineLength = sqrt(powf(targetPositionX - startPositionX, 2) + powf(targetPositionY - startPositionY, 2))
	//logmes lineLength
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	repeat lineLength
		redraw 0
		rgbcolor penColorCode
		turtlePositionX = (targetPositionX * cnt + startPositionX  * (lineLength - cnt)) / lineLength
		turtlePositionY = (targetPositionY * cnt + startPositionY  * (lineLength - cnt)) / lineLength
		//turtlePositionX = (targetPositionX - startPositionX) * cnt / lineLength
		//turtlePositionY = (targetPositionY - startPositionY) * cnt / lineLength
		;logmes "x: " + turtlePositionX + "y: " + turtlePositionY
		_makeLine@turtle startPositionX, startPositionY, turtlePositionX, turtlePositionY
		_drawAll@turtle
		redraw 1
		_waitTurtle@turtle
	loop
	rgbcolor preColor
	return
#deffunc backward double distance_
	newPositionX = cos(deg2rad(180.0 - turtleHeading)) * distance_ + turtlePositionX
	newPositionY = sin(deg2rad(180.0 - turtleHeading)) * distance_ + turtlePositionY
	_moveToNewPosition@turtle newPositionX, newPositionY
	return
#deffunc bk double distance_
	backward distance_
	return
#deffunc back double distance_
	backward distance_
	return
#deffunc fd double distance_
	forward distance_
	return
#deffunc forward double distance_
	newPositionX = cos(deg2rad(turtleHeading)) * distance_ + turtlePositionX
	newPositionY = sin(deg2rad(turtleHeading)) * distance_ + turtlePositionY
	_moveToNewPosition newPositionX, newPositionY
	return
#deffunc goto double x_, double y_
	logmes x_ - turtlePositionX
	logmes y_ - turtlePositionY

	logmes turtleHeading
	logmes rad2deg(atan((y_ - turtlePositionY), (x_ - turtlePositionX))) - turtleHeading
	logmes rad2deg(atan(y_, x_))
	_rotateTurtle rad2deg(atan((y_ - turtlePositionY), (x_ - turtlePositionX))) - turtleHeading
	//await 1000
	//_rotateTurtle rad2deg(atan(y_, x_))
	_moveToNewPosition@turtle double(x_), double(y_)
	return
#deffunc home
	goto 0.0, 0.0
	return
#deffunc initializeTurtle
	cls
	mainScreen = ginfo_sel
	buffer BUFFER_WINDOWID@, ginfo_winx, ginfo_winy
	celload "turtle.png", TURTLE_PICTURE_WINDOWID@
	gsel TURTLE_PICTURE_WINDOWID@
	pictureSizeX = ginfo_winx
	pictureSizeY = ginfo_winy
	gsel mainScreen, 1
	turtlePositionX = 0
	turtlePositionY = 0
	turtleHeading = 0
	turtleSpeed = DEFAULT_TURTLE_SPEED@
	penIsDown = true@
	turtleIsVisible = true@
	penColorCode = black@
	backgroundColor = white@
	_drawAll@turtle
	return
#deffunc left double angle_
	_rotateTurtle@turtle angle_
	return
#deffunc lt double angle_
	left angle_
	return
#deffunc pencolor int colorCode_
	penColorCode = colorCode_
	return
#deffunc pendown
	penisdown = true@
	return
#deffunc penup
	penisdown = false@
	return
#deffunc right double angle_
	_rotateTurtle@turtle -angle_
	return
#deffunc rt double angle_
	right angle_
	return
#deffunc setheading double to_angle_
	turtleHeading = to_angle_
	return
#deffunc seth double to_angle_
	setheading to_angle_
	return
#deffunc setpos double x_, double y_
	goto x_, y_
	return
#deffunc setposition double x_, double y_
	goto x_, y_
	return
#defcfunc positionX
	return double(turtlePositionX)
#defcfunc positionY
	return double(turtlePositionY)
/*
#deffunc bgcolor int colorCode_
	return
*/
#global

initializeTurtle
