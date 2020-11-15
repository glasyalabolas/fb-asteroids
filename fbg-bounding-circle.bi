#ifndef __FBGAME_BOUNDINGCIRCLE__
#define __FBGAME_BOUNDINGCIRCLE__

#include once "fbg-vec2.bi"
#include once "fbg-bounding-box.bi"

namespace FbGame
  type BoundingCircle
    declare constructor()
    declare constructor( as single, as single, as single )
    declare constructor( byref as Vec2, as single )
    declare destructor()
    
    declare function centerAt( as single, as single ) byref as BoundingCircle
    declare function inside( as single, as single ) as boolean
    declare function outside( as single, as single ) as boolean
    declare function overlapsWith( byref as BoundingCircle ) as boolean
    declare function overlapsWith( byref as BoundingBox ) as boolean
    declare function overlapVector( byref as BoundingCircle ) as Vec2
    
    as Vec2 center
    as single radius
  end type
  
  constructor BoundingCircle() : end constructor
  
  constructor BoundingCircle( aX as single, aY as single, aRadius as single )
    constructor( Vec2( aX, aY ), aRadius )
  end constructor
  
  constructor BoundingCircle( byref aCenter as Vec2, aRadius as single )
    center = aCenter
    radius = aRadius
  end constructor
  
  destructor BoundingCircle() : end destructor
  
  private function BoundingCircle.centerAt( x as single, y as single ) byref as BoundingCircle
    center.x = x : center.y = y
    return( this )
  end function
  
  private function BoundingCircle.inside( x as single, y as single ) as boolean
    return( Vec2( x, y ).distanceToSq( center ) <= radius ^ 2 )
  end function
  
  private function BoundingCircle.outside( aX as single, aY as single ) as boolean
    return( not inside( aX, aY ) )
  end function
  
  private function BoundingCircle.overlapsWith( byref another as BoundingCircle ) as boolean
    return( cbool( _
      ( center - another.center ).lengthSq() < _
        ( radius + another.radius ) ^ 2 ) )
  end function
  
  private function BoundingCircle.overlapsWith( byref bb as BoundingBox ) as boolean
    return( cbool( Vec2( _
      iif( center.x < bb.x, bb.x, iif( center.x > bb.x + bb.width, _
        bb.x + bb.width, center.x ) ), _
      iif( center.y < bb.y, bb.y, iif( center.y > bb.y + bb.height, _
        bb.y + bb.height, center.y ) ) ) _
      .distanceTo( center ) <= radius ) )
  end function
  
  private function BoundingCircle.overlapVector( byref another as BoundingCircle ) as Vec2
    return( iif( overlapsWith( another ), _
      ( center - another.center ), _
      Vec2() ) )
  end function
  
  '' We can define this once we have the BoundingCircle defined
  private function BoundingBox.overlapsWith( byref bc as BoundingCircle ) as boolean
    return( cbool( Vec2( _
      iif( bc.center.x < x, x, _
        iif( bc.center.x > x + width, x + width, bc.center.x ) ), _
      iif( bc.center.y < y, y, _
        iif( bc.center.y > y + height, y + height, bc.center.y ) ) ) _
      .distanceTo( bc.center ) <= bc.radius ) )
  end function
end namespace

#endif
