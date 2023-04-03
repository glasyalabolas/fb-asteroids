#ifndef __FBGAME_BOUNDINGBOX__
#define __FBGAME_BOUNDINGBOX__

#include once "fbg-vec2.bi"

namespace FbGame
  type as BoundingCircle BoundingCircle_
  
  type BoundingBox
    declare constructor()
    declare constructor( as single, as single, as single, as single )
    
    declare function centerAt( as single, as single ) byref as BoundingBox
    declare function inside( as single, as single ) as boolean
    declare function outside( as single, as single ) as boolean
    declare function overlapsWith( as BoundingBox ) as boolean
    declare function overlapsWith( as BoundingCircle_ ) as boolean
    declare function overlapVector( as BoundingBox ) as Vec2
    declare function insideOf( as BoundingBox ) as boolean
    
    as single x, y, width, height
  end type
  
  constructor BoundingBox() : end constructor
  
  constructor BoundingBox( aX as single, aY as single, aWidth as single, aHeight as single )
    x = aX : y = aY
    this.width = aWidth : height = aHeight
  end constructor
  
  private function BoundingBox.centerAt( aX as single, aY as single ) byref as BoundingBox
    x = aX - this.width * 0.5f : y = aY - height * 0.5f
    
    return( this )
  end function
  
  private function BoundingBox.inside( pX as single, pY as single ) as boolean
    return( cbool( _
      pX >= x andAlso pX <= x + width - 1 andAlso _
      pY >= y andAlso pY <= y + height - 1 ) )
  end function
  
  private function BoundingBox.outside( pX as single, pY as single ) as boolean
    return( not inside( pX, pY ) )
  end function
  
  private function BoundingBox.overlapsWith( another as BoundingBox ) as boolean
    return( cbool( _
      x + width - 1 >= another.x andAlso _
      y + height - 1 >= another.y andAlso _
      x <= another.x + another.width - 1 andAlso _
      y <= another.y + another.height - 1 ) )
  end function
  
  private function BoundingBox.overlapVector( bb as BoundingBox ) as Vec2
    return( Vec2( _
      iif( x - bb.x >= 0 andAlso x + width - bb.x <= bb.width, _
        0, iif( bb.x - x < -width, _
          ( bb.x + bb.width ) - ( x + width ), _
          bb.x - x ) ), _
      iif( y - bb.y >= 0 andAlso y + height - bb.y <= bb.height, _
        0, iif( bb.y - y < -height, _
          ( bb.y + bb.height ) - ( y + height ), _
          bb.y - y ) ) ) )
  end function
  
  private function BoundingBox.insideOf( another as BoundingBox ) as boolean
    return( cbool( _
      x - another.x >= 0 andAlso _
      x + width - another.x <= another.width andAlso _
      y - another.y >= 0 andAlso _
      y + height - another.y <= another.height ) )
  end function
end namespace

#endif