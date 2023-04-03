#ifndef __FBGAME_VEC2__
#define __FBGAME_VEC2__

namespace FbGame
  type Vec2
    declare constructor()
    declare constructor( as single, as single )
    
    declare operator cast() as string
    
    declare function length() as single
    declare function lengthSq() as single
    declare function makeLength( as single ) byref as Vec2
    declare function ofLength( as single ) as Vec2
    declare function normalize() byref as Vec2
    declare function normalized() as Vec2
    declare function dot( as Vec2 ) as single
    declare function cross( as Vec2 ) as single
    declare function turnLeft() byref as Vec2
    declare function turnedLeft() as Vec2
    declare function turnRight() byref as Vec2
    declare function turnedRight() as Vec2
    declare function angle() as single
    declare function rotate( as single ) byref as Vec2
    declare function rotated( as single ) as Vec2
    declare function rotate( as Vec2, as single ) byref as Vec2
    declare function rotated( as Vec2, as single ) as Vec2
    declare function distanceTo( as Vec2 ) as single
    declare function distanceToSq( as Vec2 ) as single
    declare function aligned( as Vec2, as Vec2, as Vec2 ) as Vec2
    declare function interpolated( as Vec2, as single ) as Vec2
    
    as single x, y
  end type
  
  constructor Vec2() : end constructor
  
  constructor Vec2( aX as single, aY as single )
    x = aX : y = aY
  end constructor
  
  operator Vec2.cast() as string
    return( "{x=" & x & ";y=" & y & "}" )
  end operator
  
  operator + ( lhs as Vec2, rhs as Vec2 ) as Vec2
    return( Vec2( lhs.x + rhs.x, lhs.y + rhs.y ) )
  end operator
  
  operator + ( lhs as Vec2, rhs as single ) as Vec2
    return( Vec2( lhs.x + rhs, lhs.y + rhs ) )
  end operator
  
  operator - ( lhs as Vec2, rhs as Vec2 ) as Vec2
    return( Vec2( lhs.x - rhs.x, lhs.y - rhs.y ) )
  end operator
  
  operator - ( lhs as Vec2, rhs as single ) as Vec2
    return( Vec2( lhs.x - rhs, lhs.y - rhs ) )
  end operator
  
  operator - ( rhs as Vec2 ) as Vec2
    return( Vec2( -rhs.x, -rhs.y ) )
  end operator
  
  operator * ( lhs as Vec2, rhs as Vec2 ) as Vec2
    return( Vec2( lhs.x * rhs.x, lhs.y * rhs.y ) )
  end operator
  
  operator * ( lhs as Vec2, rhs as single ) as Vec2
    return( Vec2( lhs.x * rhs, lhs.y * rhs ) )
  end operator
  
  operator / ( lhs as Vec2, rhs as Vec2 ) as Vec2
    return( Vec2( lhs.x / rhs.x, lhs.y / rhs.y ) )
  end operator
  
  operator / ( lhs as Vec2, rhs as single ) as Vec2
    return( Vec2( lhs.x / rhs, lhs.y / rhs ) )
  end operator
  
  operator sgn ( rhs as Vec2 ) as Vec2
    return( Vec2( sgn( rhs.x ), sgn( rhs.y ) ) )
  end operator
  
  private function Vec2.length() as single
    return( sqr( x ^ 2 + y ^ 2 ) )
  end function
  
  private function Vec2.lengthSq() as single
    return( x ^ 2 + y ^ 2 )
  end function
  
  private function Vec2.normalize() byref as Vec2
    dim as single l = 1.0f / length()
    
    x *= l : y *= l
    
    return( this )
  end function
  
  private function Vec2.normalized() as Vec2
    dim as single l = 1.0f / length()
    
    return( Vec2( x * l, y * l ) )
  end function
  
  private function Vec2.dot( v as Vec2 ) as single
    return( x * v.x + y * v.y )
  end function
  
  private function Vec2.cross( v as Vec2 ) as single
    return( x * v.y - y * v.x )
  end function
  
  private function Vec2.turnLeft() byref as Vec2
    this = Vec2( -y, x )
    return( this )
  end function
  
  private function Vec2.turnedLeft() as Vec2
    return( Vec2( -y, x ) )
  end function
  
  private function Vec2.turnRight() byref as Vec2
    this = Vec2( y, -x )
    return( this )
  end function
  
  private function Vec2.turnedRight() as Vec2
    return( Vec2( y, -x ) )
  end function
  
  private function Vec2.angle() as single
    return( atan2( y, x ) )
  end function
  
  private function Vec2.rotate( a as single ) byref as Vec2
    dim as single _
      si = sin( a ), _
      co = cos( a )
    
    x = x * co - y * si : y = x * si + y * co
    
    return( this )
  end function
  
  private function Vec2.rotated( a as single ) as Vec2
    dim as single _
      si = sin( a ), _
      co = cos( a )
    
    return( Vec2( x * co - y * si, x * si + y * co ) )
  end function
  
  private function Vec2.makeLength( aLength as single ) byref as Vec2
    this = Vec2( x, y ).normalize() * aLength
    return( this )
  end function
  
  private function Vec2.ofLength( aLength as single ) as Vec2
    return( Vec2( x, y ).normalize() * aLength )
  end function
  
  private function Vec2.rotate( pivot as Vec2, a as single ) byref as Vec2
    var rv = ( this - pivot ).rotate( a ) + pivot
    
    x = rv.x : y = rv.y
    
    return( this )
  end function
  
  private function Vec2.rotated( pivot as Vec2, a as single ) as Vec2
    return( ( this - pivot ).rotate( a ) + pivot )
  end function
  
  private function Vec2.distanceTo( v as Vec2 ) as single
    return( ( this - v ).length() )
  end function
  
  private function Vec2.distanceToSq( v as Vec2 ) as single
    return( ( this - v ).lengthSq() )
  end function
  
  private function Vec2.aligned( p as Vec2, s as Vec2, a as Vec2 ) as Vec2
    return( p + s * a.normalized() )
  end function
  
  private function Vec2.interpolated( v as Vec2, t as single ) as Vec2
    return( this * ( 1.0f - t ) + v * t )
  end function
end namespace

#endif
