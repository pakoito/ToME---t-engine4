/**
 *
 * This is a demo for using a bitmap font
 *
 * A bitmap font consists of 2 files
 *
 * A graphic file, containing all font characters
 * in one line, with a vertical single pixel line
 * with RGB values (255,0,255) acting as a seperator
 *
 * A map file, containing the characters as they appear
 * in the graphics file.
 *
 * The mapfile has to be called the same name as the
 * graphics file, postfixed by .map
 *
 * See files font.png and font.png.map from this
 * directory as example
 *
 * */

#include <sge.h>
#include <math.h>

// define our data that is passed to our redraw function
typedef struct {
	SGEFONT *font;
	SGEFONT *fontbig;
	char *text;
	int offset;
	float y;
	int fontHeight;
	int textWidth;
	int currentFontNumber;
	SGEFONT *currentFont;
} MainStateData;

// redraw the screen and update game logics, if any
void on_redraw(SGEGAMESTATE *state) {
	char buf[2];
	int i;
	int x;
	int width;
	float yy;

	// prepare event and data variable form the gamestat passed to that
	// function
	SGEEVENTSTATE es = state->manager->event_state;
	MainStateData *data = (MainStateData*)state->data;

	// has the user closed the window?
	if (es.start.released) {
		sgeGameStateManagerQuit(state->manager);
		return;
	}
	// switch font if user pressed y key (m on pc)
	if (es.y.released) {
		data->currentFontNumber=(data->currentFontNumber+1)%2;
		if (data->currentFontNumber) {
			data->currentFont=data->fontbig;
		} else {
			data->currentFont=data->font;
		}
		data->fontHeight=sgeFontGetLineHeight(data->currentFont);
		data->textWidth=sgeFontGetWidth(data->currentFont, data->text);
	}

	// prepare data
	sgeClearScreen();
	yy=data->y;
	// our string has to be 0 terminated
	strcpy(buf, " ");
	x=data->offset;

	// print every character
	for (i=0;i<strlen(data->text);i++) {
		// copy next char to buffer
		sprintf(buf, "%c", data->text[i]);

		// now print our character
		//
		// we use sgeFontPrintBitmap instead of sgeFontPrint
		// as sgeFontPrint is only a wrapper, so it will execute
		// faster
		//
		// do this only if can be sure, that the font is a
		// bitmap font
		width=sgeFontPrintBitmap(data->currentFont, screen, x, (cos(yy)+1)*(120-(data->fontHeight>>1)), buf);
		x+=width;
		yy+=.05;
	}

	// scroll to the left, increase cos startvalue
	data->offset-=data->currentFontNumber*2+2;
	data->y+=.1;

	// check if we have to restart the text
	if (abs(data->offset)>data->textWidth) {
		data->offset=320;
	}

	sgeFontPrintBitmap(data->font, screen, 10, 200, "m - Toggle font");

	// finally display the screen
	sgeFlip();
}

// this is the main function, you don't use main(), as this is handled different
// on some platforms
int run(int argc, char *argv[]) {
	SGEGAMESTATEMANAGER *manager;
	SGEGAMESTATE *mainstate;
	SGEFILE *f;
	MainStateData data;

	// initialize engine and set up resolution and depth
	sgeInit(NOAUDIO,NOJOYSTICK);
	sgeOpenScreen("SGE Bitmap Font",320,240,32,NOFULLSCREEN);
	sgeHideMouse();

	// add a new gamestate. you will usually have to add different gamestates
	// like 'main menu', 'game loop', 'load screen', etc.
	mainstate = sgeGameStateNew();
	mainstate->onRedraw = on_redraw;
	mainstate->data = &data;

	// prepare the data
	data.text=(char *)&"Hello World! This is a little demonstration of SGE bitmap font. See font.png and font.png.map as a example how to set up the font data. ";
	data.offset=320;
	data.y=.0;

	// load the bitmap font from the data file
	f=sgeOpenFile("data.d","asdf");
	data.font=sgeFontNewFile(f, SGEFONT_BITMAP, "font.png");
	data.fontbig=sgeFontNewFile(f, SGEFONT_BITMAP, "retro_big_color.png");
	sgeCloseFile(f);

	// precalc needed values for more speed
	data.fontHeight=sgeFontGetLineHeight(data.font);
	data.textWidth=sgeFontGetWidth(data.font, data.text);
	data.currentFontNumber=0;
	data.currentFont=data.font;

	// now finally create the gamestate manager and change to the only state
	// we defined, which is the on_redraw function
	manager = sgeGameStateManagerNew();
	sgeGameStateManagerChange(manager, mainstate);

	// start the game running with 30 frames per seconds
	sgeGameStateManagerRun(manager, 30);

	// clean up
	sgeFontDestroy(data.font);
	sgeFontDestroy(data.fontbig);

	// close the screen and quit
	sgeCloseScreen();
	return 0;
}
