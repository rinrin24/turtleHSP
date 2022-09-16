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

#const DEFAULT_WAIT 10;20
#const DEFAULT_TURTLE_SPEED 10
#const TURTLE_PICTURE_SIZEX 50
#const TURTLE_PICTURE_SIZEY 50
#const BUFFER_WINDOWID 1
#const TURTLE_PICTURE_WINDOWID 2
#const TURTLE_OTHERCOLOR_PICTURE_WINDOWID 3
#const ROTATE_MIN_UNIT 1	//degree
#const MAX_STAMPS 100
#const DEFAULT_PENSIZE 10

#undef goto
#undef width

/*ローカル変数
turtlePositionX: 亀のX座標
turtlePositionY: 亀のY座標
turtleHeading: 亀の向いている方法(度)(東が0°で反時計回りに)
turtleSpeed: 亀の移動速度
penIsDown: ペンが降りてればtrue, ペンが上がっていればfalse
turtleIsVisible: 亀が可視か
penColorCode: penの描画色(16進RGB)
backgroundColor: 背景色
turtleStamps: スタンプの位置を示す二次元配列、一次元目にスタンプのID、二次元目でスタンプのX、Y、角度、色を指定し、使用可能かを定義(0- X, 1- Y, 2- 角度, 3- 16進カラーコード, 4- 利用可能か)
turtleStampNumber: 現在存在しているスタンプの数
turtlePenSize: ペンのサイズ(px)

mainScreen: 描画先ウィンドウのウィンドウID

buffer 1: 亀以外の描画
*/

#module turtle
#deffunc local _drawAll
	rgbcolor bgcolor : boxf
	_drawShape@turtle
	_drawStamps@turtle
	_drawTurtle@turtle
	return
#deffunc local _drawShape
	gmode 0
	pos 0, 0
	gcopy 1, 0, 0, ginfo_winx, ginfo_winy
	return
#deffunc local _drawStamps
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	repeat turtleStampNumber
		if(turtleStamps(cnt, 4) == false@) : continue cnt
		gsel TURTLE_OTHERCOLOR_PICTURE_WINDOWID@, 1
		rgbcolor int(turtleStamps(cnt, 3)) : boxf
		pos 0, 0
		gmode 2
		gcopy TURTLE_PICTURE_WINDOWID@, 0, 0, pictureSizeX, pictureSizeY
		gsel mainScreen, 1
		pos turtleStamps(cnt, 0) + ginfo_winx / 2, turtleStamps(cnt, 1) + ginfo_winy / 2
		rgbcolor green@
		gmode 4, pictureSizeX, pictureSizeY, 255
		grotate TURTLE_OTHERCOLOR_PICTURE_WINDOWID@, 0, 0, deg2rad(turtleStamps(cnt, 2)), TURTLE_PICTURE_SIZEX@, TURTLE_PICTURE_SIZEY@
	loop
	rgbcolor preColor
	gmode 0
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
	;logmes turtleHeading
	grotate TURTLE_PICTURE_WINDOWID@, 0, 0, -deg2rad(turtleHeading), TURTLE_PICTURE_SIZEX@, TURTLE_PICTURE_SIZEY@
	rgbcolor preColor
	gmode 0
	return
#deffunc local _makeArc int x_, int y_, int radius_, int startPoint_, int endPoint_
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	gsel BUFFER_WINDOWID@, 1
	rgbcolor penColorCode
	repeat abs(endPoint_ - startPoint_) * 10
		curAngle = double(startPoint_) + 0.1 * cnt
		circle x_ + cos(deg2rad(curAngle)) * radius_ - pensize / 2 + ginfo_winx, y_ + sin(deg2rad(curAngle)) * radius_ - pensize / 2 + ginfo_winy, x_ + cos(deg2rad(curAngle)) * radius_ + pensize / 2 + ginfo_winx, y_ + sin(deg2rad(curAngle)) * radius_ + pensize / 2 + ginfo_winy
	loop
	gsel mainScreen, 1
	rgbcolor preColor
	return
#deffunc local _makeLine int x1_, int y1_, int x2_, int y2_
	if(penIsDown == false@) : return
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	gsel BUFFER_WINDOWID@, 1
	rgbcolor penColorCode
	if(turtlePenSize > 1) {
		_makeThickLine@turtle x1_ + ginfo_winx / 2, y1_ + ginfo_winy / 2, x2_ + ginfo_winx / 2, y2_ + ginfo_winy / 2
	}else{
		line x1_ + ginfo_winx / 2, y1_ + ginfo_winy / 2, x2_ + ginfo_winx / 2, y2_ + ginfo_winy / 2
	}
	;logmes "(" + (x1_ + ginfo_winx / 2) + "," + (y1_ + ginfo_winy / 2) + "), (" + (x2_ + ginfo_winx / 2) + "," + (y2_ + ginfo_winy / 2)
	;logmes "x: " + turtlePositionX + "y: " + turtlePositionY
	;logmes "x: " + int((turtlePositionX - TURTLE_PICTURE_SIZEX@ / 2) + ginfo_winx / 2) + ", y: " + int((turtlePositionY - TURTLE_PICTURE_SIZEY@ / 2) + ginfo_winy / 2)
	gsel mainScreen, 1
	rgbcolor preColor
	return
#deffunc local _makeThickLine int x1_, int y1_, int x2_, int y2_
	thickLineLength = sqrt(powf(x1_ - x2_, 2) + powf(y1_ - y2_, 2))
	repeat int(thickLineLength)
		curX = (x1_ * (thickLineLength - cnt) + x2_ * cnt) / thickLineLength
		curY = (y1_ * (thickLineLength - cnt) + y2_ * cnt) / thickLineLength
		circle curX - turtlePenSize / 2, curY - turtlePenSize / 2, curX + turtlePenSize / 2, curY + turtlePenSize / 2, 1
	loop
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
		;logmes lineLength
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
/**
@param 回転する角度:double
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
		if(absf(turtleHeading) >= 360) : turtleHeading = turtleHeading \ 360
		if(turtleHeading < 0) : turtleHeading = 360 + turtleHeading
		_drawAll@turtle
		redraw 1
		;logmes cnt
		;logmes turtleHeading
		_waitTurtle@turtle
	loop
	rgbcolor preColor
	return
#deffunc local _waitTurtle
	if(turtleSpeed == false@) : return	//turtleSpeedが0の場合はwait無し
	await DEFAULT_WAIT@ / turtleSpeed
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
#deffunc tcircle double radius_, double extent_
	circleArcLength = M_PI * radius_ * 2 * extent_ / 360
	centerX = turtlePositionX - radius_
	centerY = turtlePositionY
	setheading 90
	curAngle = turtleHeading
	startPositionX = turtlePositionX
	startPositionY = turtlePositionY
	repeat circleArcLength
		redraw 0
		curAngle += double(cnt) * extent_ / circleArcLength
		turtlePositionX = centerX + radius_ * cos(curAngle)
		turtlePositionY = centerY + radius_ * sin(curAngle)
		turtleHeading = 90 + curAngle
		_makeArc@turtle centerX, centerY, radius_, 0, curAngle
		_drawAll@turtle
		redraw 1
		_waitTurtle@turtle
	loop
	return
#deffunc clear
	gsel BUFFER_WINDOWID@, 1
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	rgbcolor backgroundColor : boxf
	rgbcolor preColor
	gsel mainScreen, 1
	_drawAll@turtle
	return
#deffunc clearstamp int stampId_
	turtleStamps(stampId_, 0) = 0
	turtleStamps(stampId_, 1) = 0
	turtleStamps(stampId_, 2) = 0
	turtleStamps(stampId_, 3) = 0
	turtleStamps(stampId_, 4) = false@
	turtleStampNumber --
	_drawAll@turtle
	return
#deffunc clearstamps
	dim turtleStamps, MAX_STAMPS@, 5
	turtleStampNumber = 0
	_drawAll@turtle
	return
#deffunc down
	pendown
	return
#deffunc dot
	gsel BUFFER_WINDOWID@, 1
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	rgbcolor penColorCode
	circle turtlePositionX - turtlePenSize / 2 + ginfo_winx / 2, turtlePositionY - turtlePenSize / 2 + ginfo_winy / 2, turtlePositionX + turtlePenSize / 2 + ginfo_winx / 2, turtlePositionY + turtlePenSize / 2 + ginfo_winy / 2, 1
	rgbcolor preColor
	gsel mainScreen, 1
	_drawAll@turtle
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
	logmes absf(rad2deg(atan((y_ - turtlePositionY), (x_ - turtlePositionX))))
	setheading absf(rad2deg(atan((y_ - turtlePositionY), (x_ - turtlePositionX))))
	;logmes rad2deg(atan((y_ - turtlePositionY), (x_ - turtlePositionX)))
	;logmes turtleHeading
	_moveToNewPosition@turtle double(x_), double(y_)
	return
#deffunc hideturtle
	turtleIsVisible = false@
	_drawAll@turtle
	return
#deffunc ht
	hideturtle
	return
#deffunc home
	goto 0.0, 0.0
	return
#deffunc initializeTurtle
	cls
	mainScreen = ginfo_sel
	buffer BUFFER_WINDOWID@, ginfo_winx, ginfo_winy
	celload "turtle.png", TURTLE_PICTURE_WINDOWID@
	gsel TURTLE_PICTURE_WINDOWID@, 1
	buffer TURTLE_OTHERCOLOR_PICTURE_WINDOWID@, ginfo_winx, ginfo_winy
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
	turtlePenSize = DEFAULT_PENSIZE@
	turtleStampNumber = 0
	dim turtleStamps, MAX_STAMPS@, 5
	_drawAll@turtle
	return
#deffunc left double angle_
	_rotateTurtle@turtle -angle_
	return
#deffunc lt double angle_
	left angle_
	return
#deffunc pencolor int colorCode_
	penColorCode = colorCode_
	return
#deffunc pd
	pendown
	return
#deffunc pendown
	penisdown = true@
	return
#deffunc pensize double width_
	turtlePenSize = width_
	return
#deffunc penup
	penisdown = false@
	return
#deffunc pu
	penup
	return
#deffunc right double angle_
	_rotateTurtle@turtle angle_
	return
#deffunc reset
	gsel BUFFER_WINDOWID@, 1
	cls
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
	dim turtleStamps, MAX_STAMPS@, 2
	return
#deffunc rt double angle_
	right angle_
	return
#deffunc setheading double to_angle_
	;logmes to_angle_
	if((absf(to_angle_ - turtleHeading)) <= 180) : _rotateTurtle to_angle_ - turtleHeading : return
	_rotateTurtle -to_angle_ + turtleHeading
	return
#deffunc seth double 
	setheading to_angle_
	return
#deffunc setpos double x_, double y_
	goto x_, y_
	return
#deffunc setx double x_
	goto x_, turtlePositionY
	return
#deffunc sety double y_
	goto turtlePositionX, y_
	return
#deffunc setposition double x_, double y_
	goto x_, y_
	return
#deffunc showturtle
	turtleIsVisible = true@
	_drawAll@turtle
	return
#deffunc speed double speed_
	turtleSpeed = speed_
	return
#deffunc st
	showturtle
	return
#deffunc stamp
	turtleStamps(turtleStampNumber, 0) = int(turtlePositionX)
	turtleStamps(turtleStampNumber, 1) = int(turtlePositionY)
	turtleStamps(turtleStampNumber, 2) = (turtleHeading)
	turtleStamps(turtleStampNumber, 3) = (penColorCode)
	turtleStamps(turtleStampNumber, 4) = true@
	turtleStampNumber ++
	_drawAll@turtle
	return
#deffunc up
	penup
	return
#deffunc width double width_
	pensize width_
	return
/*---------------以下戻り値ありの関数---------------*/
#defcfunc distance double x_, double y_
	return sqrt(powf(x_ - turtlePositionX, 2) + powf(y_ - turtlePositionY, 2))
#defcfunc heading
	return turtleHeading
#defcfunc isvisible
	return turtleIsVisible
#defcfunc positionX
	return double(turtlePositionX)
#defcfunc positionY
	return double(turtlePositionY)
#defcfunc posX
	return positionX
#defcfunc posY
	return positionY
#defcfunc towards double x_, double y_
	return rad2deg(atan((y_ - turtlePositionY), (x_ - turtlePositionX)))
#defcfunc xcor
	return positionX
#defcfunc ycor
	return positionY
/*
#deffunc bgcolor int colorCode_
	return
*/
#global

initializeTurtle
