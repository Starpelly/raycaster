using System.Collections;
using System;
using System.Collections;

using Trinkit.Raylib;
using static Trinkit.Raylib.Raylib;

namespace raycaster;

public class Rayroom
{
	Player player;

	int mapX = 8, mapY = 8, mapS = 64;

	List<int> map = new .()
	{
		1,1,1,1,1,1,1,1,
		1,0,1,0,0,0,0,1,
		1,0,1,0,0,0,0,1,
		1,0,1,0,0,0,0,1,
		1,0,0,0,0,0,0,1,
		1,0,0,0,0,1,0,1,
		1,0,1,0,0,0,0,1,
		1,1,1,1,1,1,1,1,
	} ~ delete _;

	private struct Player
	{
		public float x, y, deltaX, deltaY, angle;
		public float speed;

		public void Draw()
		{
			DrawRectangle((int32)x - 4, (int32)y - 4, 8, 8, YELLOW);

			DrawLine((int32)x, (int32)y, (int32)(x + deltaX * 5), (int32)(y + deltaY * 5), YELLOW);
		}
	}

	public this()
	{
		player.x = 220.383453f; player.y = 142.288284f;
		player.angle = 0.5114019f;
		player.deltaX = Trinkit.Mathf.Cos(player.angle) * 5;
		player.deltaY = Trinkit.Mathf.Sin(player.angle) * 5;
		player.speed = 0.2f;
	}

	private void DrawMap2D()
	{
		int xo = 0, yo = 0;
		int space = 2;
		for (var y < mapY)
		{
			for (var x < mapX)
			{
				var color = BLACK;
				if (map[y * mapX + x] == 1)
				{
					color = WHITE;
				}
				xo = x * mapS;
				yo = y * mapS;

				DrawRectangleRec(Trinkit.Rectangle(xo + space, yo + space, mapS - space, mapS - space), color);
			}
		}
	}

	private float Distance(float ax, float ay, float bx, float by, float angle)
	{
		return Math.Sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay));
	}

	private void DrawRays2D()
	{
		int r, mx, my, mp = 0, depthOfField;
		float rx = 0, ry = 0, rAngle, xo = 0, yo = 0, disT = 0;
		var hitWallIndex = 0;

		rAngle = player.angle - (30 * Trinkit.Mathf.Deg2Rad);
		if (rAngle < 0) { rAngle += 2 * Trinkit.Mathf.PI; } if (rAngle > 2 * Trinkit.Mathf.PI) { rAngle -= 2 * Trinkit.Mathf.PI; }

		var pi2 = Math.PI_f * 0.5f;
		var pi3 = 3 * Math.PI_f * 0.5f;

		for (r = 0; r < 60; r++)
		{
			/// ===========================---- HORIZONTAL LINES ----===========================

			depthOfField = 0;
			float disH = 1000000, hx = player.x, hy = player.y;
			var aTan = -1 / Math.Tan(rAngle);
			if (rAngle > Math.PI_f) // looking up
			{
				ry = (((int)player.y >> 6) << 6) - 0.0001f; 	rx = (player.y - ry) * aTan + player.x; 	yo = -64; 	xo = -yo * aTan;
			}
			if (rAngle < Math.PI_f) // looking down
			{
				ry = (((int)player.y >> 6) << 6) + 64; 			rx = (player.y - ry) * aTan + player.x; 	yo = 64; 	xo = -yo * aTan;
			}
			if (rAngle == 0 || rAngle == Math.PI_f) // looking straight left or right
			{
				rx = player.x;		ry = player.y;		depthOfField = 8;
			}
			while (depthOfField < 8)
			{
				mx = (int)(rx) >> 6;		my = (int)(ry) >> 6;		mp = my * mapX + mx;

				if (mp > 0 && mp < mapX * mapY && map[mp] > 0) // hit wall
				{
					hx = rx; hy = ry;
					disH = Distance(player.x, player.y, hx, hy, rAngle);
					depthOfField = 8;
					hitWallIndex = mp;

				}
				else // next line
				{

					rx += xo; ry += yo;
					depthOfField += 1;
				}
			}


			/// ===========================---- VERTICAL LINES ----===========================

			depthOfField = 0;
			float disV = 1000000, vx = player.x, vy = player.y;
			var nTan = -Math.Tan(rAngle);
			if (rAngle > pi2 && rAngle < pi3) // looking left
			{
				rx = (((int)player.x >> 6) << 6) - 0.0001f; 	ry = (player.x - rx) * nTan + player.y; 	xo = -64; 	yo = -xo * nTan;
			}
			if (rAngle < pi2 || rAngle > pi3) // looking right
			{
				rx = (((int)player.x >> 6) << 6) + 64; 			ry = (player.x - rx) * nTan + player.y; 	xo = 64; 	yo = -xo * nTan;
			}
			if (rAngle == 0 || rAngle == Math.PI_f) // looking straight up or down
			{
				rx = player.x;		ry = player.y;		depthOfField = 8;
			}
			while (depthOfField < 8)
			{
				mx = (int)(rx) >> 6;		my = (int)(ry) >> 6;		mp = my * mapX + mx;

				if (mp > 0 && mp < mapX * mapY && map[mp] > 0) // hit wall
				{
					vx = rx; vy = ry;
					disV = Distance(player.x, player.y, vx, vy, rAngle);
					depthOfField = 8;
					hitWallIndex = mp;
				}
				else  // next line
				{
					rx += xo; ry += yo;
					depthOfField += 1;
				}
			}
			var color = Trinkit.Color.lightGray;
			var color2 = Trinkit.Color.gray;

			if (disV < disH) { rx = vx; ry = vy; disT = (int)disV; color = Trinkit.Color(color.r, color.g, color.b, 1.0f); } // vertical wall hit
			if (disH < disV) { rx = hx; ry = hy; disT = (int)disH; color = color2; } // horizontal wall hit

			DrawLineEx(Trinkit.Vector2(player.x, player.y), Trinkit.Vector2(rx, ry), 1, color);


			/// ===========================----DRAW 3D WALLS ----===========================

			var ca = player.angle - rAngle; if (ca < 0) { ca += 2 * Trinkit.Mathf.PI; } if (ca > 2 * Trinkit.Mathf.PI) { ca -= 2 * Trinkit.Mathf.PI; }
			disT *= Trinkit.Mathf.Cos(ca);

			var lineH = (mapS * 320) / disT;
			if (lineH > 320) lineH = 320;
			var lineO = 160 - lineH * 0.5f;
			DrawLineEx(Trinkit.Vector2(r*8+530, lineO), Trinkit.Vector2(r*8+530, lineH + lineO), 8, color);

			rAngle += Trinkit.Mathf.Deg2Rad;
			if (rAngle < 0) { rAngle += 2 * Trinkit.Mathf.PI; } if (rAngle > 2 * Trinkit.Mathf.PI) { rAngle -= 2 * Trinkit.Mathf.PI; }
		}
	}

	public void Update()
	{
		var rotateSpd = 0.03f;
		if (IsKeyDown((int32)Trinkit.KeyCode.A))
		{
			player.angle -= rotateSpd;
			if (player.angle < 0) { player.angle += 2 * Trinkit.Mathf.PI; }
			player.deltaX = Trinkit.Mathf.Cos(player.angle) * 5;
			player.deltaY = Trinkit.Mathf.Sin(player.angle) * 5;
		}
		if (IsKeyDown((int32)Trinkit.KeyCode.D))
		{
			player.angle += rotateSpd;
			if (player.angle > 2 * Trinkit.Mathf.PI) { player.angle -= 2 * Trinkit.Mathf.PI; }
			player.deltaX = Trinkit.Mathf.Cos(player.angle) * 5;
			player.deltaY = Trinkit.Mathf.Sin(player.angle) * 5;
		}
		if (IsKeyDown((int32)Trinkit.KeyCode.W))
		{
			player.x += player.deltaX * player.speed;
			player.y += player.deltaY * player.speed;
		}
		if (IsKeyDown((int32)Trinkit.KeyCode.S))
		{
			player.x -= player.deltaX * player.speed;
			player.y -= player.deltaY * player.speed;
		}
	}

	public void Draw()
	{
		DrawMap2D();
		DrawRays2D();

		player.Draw();
	}
}