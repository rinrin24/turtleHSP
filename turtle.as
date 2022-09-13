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
#const ROTATE_MIN_UNIT 1	//degree
#const MAX_STAMPS 100
#const DEFAULT_PENSIZE 4

#undef goto

/*���[�J���ϐ�
turtlePositionX: �T��X���W
turtlePositionY: �T��Y���W
turtleHeading: �T�̌����Ă�����@(�x)(����0���Ŕ����v����)
turtleSpeed: �T�̈ړ����x
penIsDown: �y�����~��Ă��true, �y�����オ���Ă����false
turtleIsVisible: �T������
penColorCode: pen�̕`��F(16�iRGB)
backgroundColor: �w�i�F
turtleStamps: �X�^���v�̈ʒu�������񎟌��z��A�ꎟ���ڂɃX�^���v��ID�A�񎟌��ڂŃX�^���v��X�AY�A�F���w��(0- X, 1- Y, 2- 16�i�J���[�R�[�h)
turtleStampNumber: ���ݑ��݂��Ă���X�^���v�̐�
turtlePenSize: �y���̃T�C�Y(px)

mainScreen: �`���E�B���h�E�̃E�B���h�EID

buffer 1: �T�ȊO�̕`��
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
		pos turtleStamps(cnt, 0), turtleStamps(cnt, 1)
		rgbcolor turtleStamps(cnt, 2)
		
	loop
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
	;logmes "(" + (x1_ + ginfo_winx / 2) + "," + (y1_ + ginfo_winy / 2) + "), (" + (x2_ + ginfo_winx / 2) + "," + (y2_ + ginfo_winy / 2)
	//logmes "x: " + turtlePositionX + "y: " + turtlePositionY
	;logmes "x: " + int((turtlePositionX - TURTLE_PICTURE_SIZEX@ / 2) + ginfo_winx / 2) + ", y: " + int((turtlePositionY - TURTLE_PICTURE_SIZEY@ / 2) + ginfo_winy / 2)
	gsel mainScreen, 1
	rgbcolor preColor
	return
/**
@param ��]����p�x:double
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
	if(turtleSpeed == false@) : return	//turtleSpeed��0�̏ꍇ��wait����
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
#deffunc clear
	gsel BUFFER_WINDOWID@, 1
	preColor = ginfo_r * 255 * 255 + ginfo_g * 255 + ginfo_b
	rgbcolor backgroundColor : boxf
	rgbcolor preColor
	gsel mainScreen, 1
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
	setheading rad2deg(atan((y_ - turtlePositionY), (x_ - turtlePositionX)))
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
	_drawAll@turtle
	dim turtleStamps, MAX_STAMPS@, 2
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
	logmes to_angle_
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
	turtleStamps(turtleStampNumber, 0) = turtlePositionX
	turtleStamps(turtleStampNumber, 1) = turtlePositionY
	turtleStamps(turtleStampNumber, 2) = pencolor
	_drawAll@turtle
	return
#deffunc up
	penup
	return
#deffunc width double width_
	pensize width_
	return
/*---------------�ȉ��߂�l����̊֐�---------------*/
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
