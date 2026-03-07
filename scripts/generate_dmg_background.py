#!/usr/bin/env python3
"""Generate a DMG background image with install instructions using macOS CoreGraphics."""

import os

# macOS native frameworks
import Quartz
from CoreText import (
    CTFontCreateWithName,
    CTLineDraw,
    CTLineCreateWithAttributedString,
    CTLineGetTypographicBounds,
    kCTFontAttributeName,
    kCTForegroundColorAttributeName,
)
from CoreFoundation import (
    CFAttributedStringCreate,
)
import CoreFoundation

WIDTH = 660 * 2
HEIGHT = 400 * 2


def create_context(width, height):
    cs = Quartz.CGColorSpaceCreateDeviceRGB()
    ctx = Quartz.CGBitmapContextCreate(
        None, width, height, 8, width * 4, cs,
        Quartz.kCGImageAlphaPremultipliedLast
    )
    # Flip coordinate system (origin top-left)
    Quartz.CGContextTranslateCTM(ctx, 0, height)
    Quartz.CGContextScaleCTM(ctx, 1, -1)
    return ctx


def fill_background(ctx, width, height, r, g, b):
    Quartz.CGContextSetRGBFillColor(ctx, r, g, b, 1.0)
    Quartz.CGContextFillRect(ctx, Quartz.CGRectMake(0, 0, width, height))


def draw_text(ctx, text, x, y, font_name, font_size, r, g, b, centered=False):
    font = CTFontCreateWithName(font_name, font_size, None)
    color = Quartz.CGColorCreateGenericRGB(r, g, b, 1.0)
    attrs = {
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: color,
    }
    attr_string = CFAttributedStringCreate(None, text, attrs)
    line = CTLineCreateWithAttributedString(attr_string)

    # Get text width for centering
    text_width, _, _, _ = CTLineGetTypographicBounds(line, None, None, None)

    draw_x = x - text_width / 2 if centered else x

    # CoreText draws in unflipped coords, so we need to save/restore and unflip
    Quartz.CGContextSaveGState(ctx)
    Quartz.CGContextTranslateCTM(ctx, draw_x, y + font_size)
    Quartz.CGContextScaleCTM(ctx, 1, -1)
    Quartz.CGContextSetTextPosition(ctx, 0, 0)
    CTLineDraw(line, ctx)
    Quartz.CGContextRestoreGState(ctx)


def draw_dashed_arrow(ctx, x1, y, x2, r, g, b, thickness=6):
    """Draw a dashed arrow with arrowhead."""
    Quartz.CGContextSaveGState(ctx)
    Quartz.CGContextSetRGBStrokeColor(ctx, r, g, b, 1.0)
    Quartz.CGContextSetLineWidth(ctx, thickness)
    Quartz.CGContextSetLineDash(ctx, 0, [20, 14], 2)

    # Draw dashed line
    arrow_end = x2 - 30
    Quartz.CGContextMoveToPoint(ctx, x1, y)
    Quartz.CGContextAddLineToPoint(ctx, arrow_end, y)
    Quartz.CGContextStrokePath(ctx)
    Quartz.CGContextRestoreGState(ctx)

    # Arrowhead (solid triangle)
    Quartz.CGContextSaveGState(ctx)
    Quartz.CGContextSetRGBFillColor(ctx, r, g, b, 1.0)
    head_size = 28
    Quartz.CGContextMoveToPoint(ctx, arrow_end - 4, y - head_size)
    Quartz.CGContextAddLineToPoint(ctx, arrow_end + head_size + 4, y)
    Quartz.CGContextAddLineToPoint(ctx, arrow_end - 4, y + head_size)
    Quartz.CGContextClosePath(ctx)
    Quartz.CGContextFillPath(ctx)
    Quartz.CGContextRestoreGState(ctx)


def save_png(ctx, path, width, height):
    image = Quartz.CGBitmapContextCreateImage(ctx)
    url = Quartz.CFURLCreateWithFileSystemPath(
        None, path, Quartz.kCFURLPOSIXPathStyle, False
    )
    dest = Quartz.CGImageDestinationCreateWithURL(url, "public.png", 1, None)
    # Set DPI to 144 for retina (@2x)
    properties = {
        Quartz.kCGImagePropertyDPIWidth: 144,
        Quartz.kCGImagePropertyDPIHeight: 144,
    }
    Quartz.CGImageDestinationAddImage(dest, image, properties)
    Quartz.CGImageDestinationFinalize(dest)


def main():
    ctx = create_context(WIDTH, HEIGHT)

    # Background - soft white/gray
    fill_background(ctx, WIDTH, HEIGHT, 0.961, 0.961, 0.969)

    center_x = WIDTH / 2

    # Title
    draw_text(ctx, "Install Easy Calendar Widget",
              center_x, 50, "Helvetica Neue Bold", 52, 0.12, 0.12, 0.12, centered=True)

    # Subtitle
    draw_text(ctx, "Drag the app to your Applications folder",
              center_x, 120, "Helvetica Neue", 28, 0.47, 0.47, 0.47, centered=True)

    # Dashed arrow between icon positions
    # App icon at 180*2=360, Applications at 480*2=960
    draw_dashed_arrow(ctx, 440, 340, 860, 0.0, 0.48, 1.0, thickness=6)

    # Step labels at bottom
    step_y = 530
    col1 = WIDTH * 0.20
    col2 = WIDTH * 0.50
    col3 = WIDTH * 0.80

    # Step numbers (accent blue)
    draw_text(ctx, "1", col1, step_y - 50, "Helvetica Neue Bold", 36,
              0.0, 0.48, 1.0, centered=True)
    draw_text(ctx, "2", col2, step_y - 50, "Helvetica Neue Bold", 36,
              0.0, 0.48, 1.0, centered=True)
    draw_text(ctx, "3", col3, step_y - 50, "Helvetica Neue Bold", 36,
              0.0, 0.48, 1.0, centered=True)

    # Step descriptions
    draw_text(ctx, "Drag to Applications", col1, step_y,
              "Helvetica Neue Medium", 22, 0.2, 0.2, 0.2, centered=True)
    draw_text(ctx, "Open the app once", col2, step_y,
              "Helvetica Neue Medium", 22, 0.2, 0.2, 0.2, centered=True)
    draw_text(ctx, "Add widget to desktop", col3, step_y,
              "Helvetica Neue Medium", 22, 0.2, 0.2, 0.2, centered=True)

    # Sub-descriptions
    sub_y = step_y + 36
    draw_text(ctx, "(no dock icon will appear)", col2, sub_y,
              "Helvetica Neue", 17, 0.55, 0.55, 0.55, centered=True)
    draw_text(ctx, "Right-click desktop > Edit Widgets", col3, sub_y,
              "Helvetica Neue", 17, 0.55, 0.55, 0.55, centered=True)

    # Save
    output_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(output_dir, "dmg_background.png")
    save_png(ctx, output_path, WIDTH, HEIGHT)
    print(f"Generated {output_path} ({WIDTH}x{HEIGHT})")


if __name__ == "__main__":
    main()
