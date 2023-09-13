using System;
using Trinkit.Raylib;
using System.Collections;
using static Trinkit.Raylib.Raylib;

namespace raycaster;

class Program
{
	static Rayroom room = new .() ~ delete _;
	

	public static int Main(String[] args)
	{
		InitWindow(1280, 720, "Raycaster");
		SetTargetFPS(185);

		while (!WindowShouldClose())
		{
			room.Update();

			BeginDrawing();
			ClearBackground(DARKGRAY);

			room.Draw();

			EndDrawing();
		}

		CloseWindow();
		return 0;
	}
}