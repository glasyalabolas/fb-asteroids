#ifndef __FBGAME_POLAR__
#define __FBGAME_POLAR__

#include once "fbg-vec2.bi"

namespace FbGame
  '' Represents a polar coordinate
  type Polar
    declare constructor()
    declare constructor( as single, as single )
    declare constructor( byref as Vec2 )
    
    declare operator cast() as Vec2
    
    as single r, t
  end type
  
  constructor Polar() : end constructor
  
  constructor Polar( aR as single, aT as single )
    r = aR
    t = aT
  end constructor
  
  constructor Polar( byref aV as Vec2 )
    r = sqr( aV.x ^ 2 + aV.y ^ 2 )
    t = atan2( aV.y, aV.x )
  end constructor
  
  operator Polar.cast() as Vec2
    return( Vec2( r * cos( t ), r * sin( t ) ) )
  end operator
end namespace

#endif
