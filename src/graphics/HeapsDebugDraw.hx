package graphics;

import h2d.Object;
import h2d.Graphics;
import box2d.callbacks.DebugDraw;
import box2d.common.Vec2;
import box2d.common.Color3f;
import box2d.particle.ParticleColor;

import haxe.ds.Vector;

class HeapsDebugDraw extends DebugDraw {
    
    var graphics: Graphics;

    public function new(parent: Object) {
        super(null);
        graphics = new Graphics(parent);
        setFlags(DebugDraw.e_shapeBit);
        trace(getFlags());
    }

    override public function clear() {
        graphics.clear();
    }

    override public function drawParticlesWireframe(centers : Vector<Vec2>, radius : Float, colors : Vector<ParticleColor>, count : Int) : Void {
        drawParticles(centers, radius, colors, count);
    }

    override public function drawParticles(centers : Vector<Vec2>, radius : Float, colors : Vector<ParticleColor>, count : Int) : Void {
        var i = 0;
        for (c in centers) {
            if (colors != null && colors.length >= i)
                graphics.lineStyle(1, colors[i].color);
            else
                graphics.lineStyle(1, 0x0000ff);
            graphics.drawCircle(c.x, c.y, radius);
            i++;
        }
    }

    override public function drawSegment(p1 : Vec2, p2 : Vec2, color : Color3f) : Void {
        graphics.lineStyle(1, color.color);
        graphics.moveTo(p1.x, p1.y);
        graphics.lineTo(p2.x, p2.y);
    }

    override public function drawPoint(argPoint : Vec2, argRadiusOnScreen : Float, argColor : Color3f) : Void {
        graphics.lineStyle(1, argColor.color);
        graphics.drawCircle(argPoint.x, argPoint.y, argRadiusOnScreen);
    }

    override public function drawSolidPolygon(vertices : Vector<Vec2>, vertexCount : Int, color : Color3f) : Void {
        graphics.beginFill(color.color);
        drawPolygon(vertices, vertexCount, color);
        graphics.endFill();
    }

    override public function drawCircle(center : Vec2, radius : Float, color : Color3f) : Void {
        graphics.lineStyle(1, color.color);
        graphics.drawCircle(center.x, center.y, radius);
    }

    override public function drawSolidCircle(center : Vec2, radius : Float, axis : Vec2, color : Color3f) : Void {
        graphics.beginFill(color.color);
        drawCircle(center, radius, color);
        graphics.endFill();
    }
}