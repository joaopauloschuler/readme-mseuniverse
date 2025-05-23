
# Fractal Tree

## Overview

This project is a demonstration of recursive drawing techniques using Free Pascal, the MSEgui graphical user interface framework, and the powerful BGRABitmap library. It renders a randomized, fractal-like tree structure on a window canvas, showcasing basic GUI programming, event handling, and advanced 2D graphics features like anti-aliasing, gradients, and text rendering with effects. The primary goal is to provide a clear, documented example for developers interested in graphics programming and GUI development with Free Pascal.

## Features

*   **Recursive Drawing:** Implements the core fractal tree generation using a recursive procedure.
*   **MSEgui Integration:** Utilizes the MSEgui framework for creating the main application window and handling paint events.
*   **BGRABitmap Graphics:** Leverages BGRABitmap for rendering, offering capabilities such as:
    *   Anti-aliased line drawing (`DrawLineAntialias`).
    *   Gradient background fills (`GradientFill`).
    *   Standard text rendering (`TextOut`).
    *   Rotated text rendering with gradient colors (`TextOutAngle`, `TBGRAHueGradient`, `TBGRAGradientScanner`).
    *   Basic shape drawing (`Rectangle`).
    *   Off-screen drawing using a `tbgrabitmap` object for flicker-free rendering.
*   **Randomized Generation:** Incorporates randomness in branch angles to produce a unique tree appearance on each execution.
*   **Scalable Rendering:** The tree size scales relative to the paintbox dimensions via a calculated multiplier.

## Code Structure

The project is organized into standard Free Pascal units and a main program file:

*   `fractal_tree.pas`: The entry point of the application. It initializes the MSEgui application environment, registers the main form from its definition data, creates an instance of the main form (`tmainfo`), and starts the application's message loop (`application.run`). This file requires the `main` unit and MSEgui/MSEforms units.
*   `main.pas`: This is the core unit containing the main form class definition (`tmainfo`) and the primary drawing logic. It includes the recursive `drawTree` procedure and the `tpaintbox1_onpaint` event handler where all drawing is initiated. This unit relies on various MSEgui, MSEgraphics, and BGRABitmap units.
*   `main_mfm.pas`: Contains binary data representing the visual layout and properties of the `tmainfo` form. This file is typically generated by a form designer tool (often integrated into IDEs like Lazarus) and is not meant for manual editing. It is linked to the `main` unit via the `initialization` section which registers the form data.

## Detailed Implementation (`main.pas`)

The bulk of the application's logic resides within the `main` unit. This unit defines the `tmainfo` class, which inherits from `tmainform` (provided by MSEgui), and implements the drawing functionality in the `tpaintbox1_onpaint` procedure and the helper `drawTree` procedure.

### `tmainfo` Class

The `tmainfo` class represents the main window of the application. It contains components defined in `main_mfm.pas` and implements event handlers. The key component is `tpaintbox1: tpaintbox;`, an area within the form specifically designated for custom drawing.

The `tpaintbox1_onpaint` procedure is the event handler assigned to the `onpaint` event of `tpaintbox1`. This procedure is automatically called by the GUI framework whenever the `tpaintbox1` area needs to be redrawn.

### `tpaintbox1_onpaint(const sender: twidget; const acanvas: tcanvas);`

This procedure orchestrates the drawing process.

1.  **Off-Screen Bitmap:**
    ```pascal
    bmp := tbgrabitmap.create(sender.bounds_cx, sender.bounds_cy);
    ```
    A `tbgrabitmap` object, `bmp`, is created. This acts as an off-screen canvas with the same dimensions as the `tpaintbox1` widget (`sender`). Drawing to an off-screen bitmap first and then copying it to the visible canvas (`acanvas`) at the end prevents flickering during redraws, a common technique in GUI graphics.

2.  **Scaling Multiplier:**
    ```pascal
    multiplier := sender.bounds_cy / 50;
    ```
    A `multiplier` is calculated based on the height of the paintbox. This value is used in the `drawTree` procedure to scale the length of the tree branches relative to the window size, making the tree fit appropriately regardless of the window height (though the factor of 50 is arbitrary and can be adjusted).

3.  **Background Gradient:**
    ```pascal
    bmp.GradientFill(0, 0, bmp.Width, bmp.Height, cl_dkgreen, BGRA(0,125,0),
    gtLinear, PointF(0,0), PointF(0, bmp.Height), dmSet);
    ```
    The `bmp` is filled with a vertical linear gradient.
    *   `(0, 0, bmp.Width, bmp.Height)`: Defines the rectangle to fill (the entire bitmap).
    *   `cl_dkgreen`: The starting color (a standard Lazarus/MSEgui color constant for dark green).
    *   `BGRA(0,125,0)`: The ending color, specified directly using the `BGRA` constructor (Green with full alpha).
    *   `gtLinear`: Specifies a linear gradient type.
    *   `PointF(0,0), PointF(0, bmp.Height)`: Defines the direction of the linear gradient, from the top-left corner to the bottom-left corner.
    *   `dmSet`: Specifies the drawing mode (simply sets the pixel colors).

4.  **Drawing the Fractal Tree:**
    ```pascal
    drawTree(bmp.Width div 2, bmp.Height, -91, 9, multiplier, bmp);
    ```
    The recursive `drawTree` procedure is called to render the tree onto the `bmp`.
    *   `(bmp.Width div 2, bmp.Height)`: The starting point of the tree (bottom center of the bitmap).
    *   `-91`: The initial angle in degrees (slightly left of vertical upwards, which would typically be -90 or 270 degrees depending on the coordinate system convention).
    *   `9`: The initial recursion depth. This value determines the initial length of the trunk segment and influences how many recursion levels will be executed before the base case (`depth <= 0`) is reached.
    *   `multiplier`: The scaling factor calculated earlier, applied within `drawTree` to the length calculation.
    *   `bmp`: The `tbgrabitmap` object to draw onto.

5.  **Drawing Text and Decorations:**
    The code then proceeds to draw sample text and horizontal lines using BGRABitmap's text and shape drawing functions.
    *   `bmp.FontFullHeight := 30;`: Sets the font size.
    *   `textWidth := bmp.TextSize(SampleText).cx;`: Calculates the width of the text string in the current font.
    *   `bmp.TextOut(MarginX, MarginY, SampleText, BGRAWhite);`: Draws the `SampleText` at a specific position (`MarginX`, `MarginY`) in white (`BGRAWhite`).
    *   `bmp.HorizLine(...)`: Draws horizontal lines for decoration.
    *   The code then changes font settings (`FontFullHeight`, `FontStyle`) and demonstrates drawing text rotated by 90 degrees (`TextOutAngle`). Note that the angle `900` is interpreted as 90.0 degrees because `TextOutAngle` expects the angle multiplied by 10.
    *   A gradient (`TBGRAHueGradient`) and a scanner (`TBGRAGradientScanner`) are created and used with `TextOutAngle` to apply a color gradient to the rotated text. This is an example of BGRABitmap's advanced text rendering features.
    *   `scan.Free; grad.Free;`: The gradient and scanner objects are freed to release memory.

6.  **Borders:**
    ```pascal
    bmp.Rectangle(0, 0, bmp.Width, bmp.Height, BGRABlack);
    bmp.Rectangle(5, 5, bmp.Width - 5, bmp.Height - 5, BGRABlack);
    ```
    Two black rectangles are drawn to create a double border effect around the edge of the bitmap. The coordinates define the top-left and bottom-right corners of the rectangles.

7.  **Final Draw and Cleanup:**
    ```pascal
    bmp.draw(acanvas, 0, 0, false);
    bmp.free;
    ```
    The completed off-screen bitmap (`bmp`) is copied onto the actual visible canvas (`acanvas`) of the paintbox at coordinates (0,0). Finally, the `bmp` object is freed to release the memory it occupied.

### `drawTree(x1, y1, angle, depth, multiplier: single; bgra : tbgrabitmap);`

This is the recursive procedure that generates the tree structure.

*   **Parameters:**
    *   `x1, y1`: Starting coordinates (single-precision float) for the current branch segment.
    *   `angle`: Direction (in degrees, single-precision float) of the current branch.
    *   `depth`: Current recursion level (single-precision float). Controls segment length and recursion termination.
    *   `multiplier`: Global scaling factor.
    *   `bgra`: The `tbgrabitmap` object to draw on.

*   **Recursion Logic:**
    ```pascal
    if (depth > 0) then
    begin
      // ... calculate x2, y2 ...
      // ... draw line from (x1, y1) to (x2, y2) ...
      // ... make recursive calls ...
    end;
    ```
    The base case for the recursion is when `depth` is no longer greater than 0. This prevents infinite recursion.

*   **Calculating End Point (`x2, y2`):**
    ```pascal
    x2 := x1 + (cos(angle * deg_to_rad) * depth * multiplier);
    y2 := y1 + (sin(angle * deg_to_rad) * depth * multiplier);
    ```
    The end point (`x2`, `y2`) of the current branch segment is calculated using trigonometry.
    *   `angle * deg_to_rad`: Converts the angle from degrees to radians, as `cos` and `sin` functions typically expect radians. `deg_to_rad` is a constant `pi / 180`.
    *   `depth * multiplier`: This product determines the length of the current branch segment. The `depth` value decreases with each recursive call, making branches shorter further from the base. The `multiplier` scales the entire tree.
    *   `cos(...) * length` and `sin(...) * length`: Standard trigonometric method to find the `x` and `y` displacements from the start point based on angle and length. Note that in screen coordinates, positive Y is typically downwards, while standard trigonometric units assume positive Y upwards. The initial angle of -91 degrees correctly points mostly upwards in this coordinate system.

*   **Drawing the Branch:**
    ```pascal
    bgra.DrawLineAntialias(x1, y1, x2, y2, BGRABlack, depth, False);
    ```
    A line segment is drawn from the start (`x1`, `y1`) to the calculated end point (`x2`, `y2`).
    *   `BGRABlack`: The color of the line.
    *   `depth`: **Crucially, this parameter is used as the line thickness.** This creates the visual effect of a thick trunk near the base (high initial `depth`) tapering to thin twigs at the extremities (low `depth`).
    *   `False`: For the `ADrawBothEnds` parameter, which affects how line endings are drawn (not significant here as thickness is the main visual factor).

*   **Recursive Calls (Branching):**
    ```pascal
    drawTree(x2, y2, angle - randomrange(15,50), depth - 1.44, multiplier, bgra);
    drawTree(x2, y2, angle + randomrange(10,25), depth - 0.72, multiplier, bgra);
    drawTree(x2, y2, angle - randomrange(10,25), depth - 3, multiplier, bgra);
    drawTree(x2, y2, angle + randomrange(15,50), depth - 4, multiplier, bgra);
    ```
    Four recursive calls are made from the end point (`x2`, `y2`) of the current branch. Each call represents a new sub-branch.
    *   **New Angle:** The angle for each sub-branch is calculated by adding or subtracting a *random* value using `randomrange(Low, High)`. This random deviation from the parent branch's angle is what makes the tree appear non-symmetrical and different each time it's run. The specific ranges (`15-50`, `10-25`) and whether they are added or subtracted define the spread and direction of the branching. Experimenting with these ranges dramatically changes the tree's shape.
    *   **New Depth:** The `depth` is reduced by fixed fractional values (`1.44`, `0.72`, `3`, `4`). These fixed decrements mean the length reduction isn't strictly proportional, contributing to the "fractal-like" rather than true fractal nature. The different decrement values mean the four sub-branches generated at each step will have different potential maximum lengths (`depth - 0.72` allows for longer subsequent branches than `depth - 4`). These specific values (1.44, 0.72, 3, 4) are empirical and significantly shape the tree's structure. Modifying them is a key way to alter the tree's appearance.

The comment "// Use even values without randomness to get a 'real' fractal image" indicates that replacing `randomrange(Low, High)` with a fixed value (e.g., a constant `AngleDelta`) would remove the randomness and produce a deterministic tree, though still influenced by the unequal depth reductions. For a true fractal where shape repeats perfectly at different scales, the angle changes and depth reductions would need to follow a more consistent, proportional rule.


