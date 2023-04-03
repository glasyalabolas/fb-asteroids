#ifndef __FBGAME_UTILS__
#define __FBGAME_UTILS__

#include once "fbg-vec2.bi"

namespace FbGame
  const as single _
    C_PI = 4.0f * atn( 1.0f ), _
    C_TWOPI = 2.0f * C_PI, _
    C_DEGTORAD = C_PI / 180.0f, _
    C_RADTODEG = 180.0f / C_PI
  
  private function toRad( a as single ) as single
    return( a * C_DEGTORAD )
  end function
  
  private function toDeg( a as single ) as single
    return( a * C_RADTODEG )
  end function
  
  private function max( a as single, b as single ) as single
    return( iif( a > b, a, b ) )
  end function
  
  private function min( a as single, b as single ) as single
    return( iif( a < b, a, b ) )
  end function
  
  private function fMod( n as single, d as single ) as single
    return( n - int( n / d ) * d )
  end function
  
  private function wrap( v as single, a as single, b as single ) as single
    return( fMod( v - a, b - a ) + a )
  end function
  
  private function wrapV( _
      byref v as Vec2, x1 as single, y1 as single, x2 as single, y2 as single ) _
    as Vec2
    
    return( Vec2( wrap( v.x, x1, x2 ), wrap( v.y, y1, y2 ) ) )
  end function
  
  private function rng overload( aMin as integer, aMax as integer ) as integer
    return( int( rnd() * ( ( aMax + 1 ) - aMin ) + aMin ) )
  end function
  
  private function rng( aMin as double, aMax as double ) as double
    return( rnd() * ( aMax - aMin ) + aMin )
  end function
  
  private function alignedCenter( x as single, w as single ) as single
    return( ( w - x ) * 0.5f )
  end function
  
  private function alignedRight( x as single, w as single ) as single
    return( w - x )
  end function
  
  private sub debugOut( t as const string )
    dim as long f = freeFile()
    
    open cons for output as f
      ? #f, t
    close( f )
  end sub
end namespace

#endif
