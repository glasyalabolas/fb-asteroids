#include once "fb-game.bi"

using FbGame

/'
  Enumerations, constants and utility functions
'/

'' Scales the velocity of the player-asteroid impact.
'' Controls how much damage the player ship takes when
'' colliding with asteroids. 
const as single C_DAMAGE_SCALE = 0.007f

enum Colors
  White  = rgba( 255, 255, 255, 255 )
  Red    = rgba( 255, 0, 0, 255 )
  Yellow = rgba( 255, 255, 0, 255 )
  Blue   = rgba( 0, 0, 255, 255 )
end enum

'' Returns a normalized vector in a random direction
function rndNormal() as Vec2
  return( Vec2( rng( -1.0f, 1.0f ), rng( -1.0f, 1.0f ) ).normalized() )
end function

'' Returns a position within an area
function rngWithin( bb as BoundingBox ) as Vec2
  return( Vec2( rng( bb.x, bb.width ), rng( bb.y, bb.height ) ) )
end function

/'
  Represents a spaceship that can move and fire
'/
type Ship
  declare constructor()
  declare constructor( as Vec2 )
  declare constructor( as Vec2, as single )
  declare constructor( as Vec2, as Vec2, as single )
  declare destructor()
  
  as Vec2 pos, dir, vel, acc
  as single _
    size, maxSpeed, _
    rateOfFire, accel, _
    turnSpeed
end type

constructor Ship()
  constructor( Vec2(), Vec2( 0.0f, -1.0f ), 10.0f )
end constructor

constructor Ship( aPos as Vec2 )
  constructor( aPos, Vec2( 0.0f, -1.0f ), 10.0f )
end constructor

constructor Ship( aPos as Vec2, aSize as single )
  constructor( aPos, Vec2( 0.0f, -1.0f ), aSize )
end constructor

constructor Ship( aPos as Vec2, aDir as Vec2, aSize as single )
  pos = aPos
  dir = aDir.normalized()
  size = aSize
  rateOfFire = 100.0f
  accel = 550.0f
  turnSpeed = 360.0f
end constructor

destructor Ship() : end destructor

'' Represents the keys used for player controls
type PlayerControls
  as long _
    forward, backward, _
    rotateLeft, rotateRight, _
    fire, strafe
end type

'' Represents a player
type Player
  declare constructor()
  declare constructor( as Ship )
  declare destructor()
  
  as Ship playerShip
  as single health
  as long score
end type

constructor Player()
  constructor( Ship( Vec2(), 20.0f ) )
end constructor

constructor Player( aShip as Ship )
  playerShip = aShip
  health = 100.0f
end constructor

destructor Player() : end destructor

'' Represents an asteroid
type Asteroid
  declare constructor()
  declare constructor( as Vec2, as Vec2, as single )
  declare destructor()
  
  as Vec2 pos, vel
  as single size, health
  as ulong color
end type

constructor Asteroid()
  constructor( Vec2(), Vec2(), 0.0f )
end constructor

constructor Asteroid( aPos as Vec2, aVel as Vec2, aSize as single )
  pos = aPos
  vel = aVel
  size = aSize
  health = 100.0f
  color = Colors.Red
end constructor

destructor Asteroid() : end destructor

'' Represents a bullet
type Bullet
  declare constructor()
  declare constructor( as Vec2, as Vec2 )
  declare constructor( as Vec2, as Vec2, as single )
  declare constructor( as Vec2, as Vec2, as single, as single, as single )
  declare destructor()
  
  as Vec2 pos, dir
  as single size, speed, lifetime
end type

constructor Bullet()
  constructor( Vec2(), Vec2(), 4.0f )
end constructor

constructor Bullet( aPos as Vec2, aDir as Vec2 )
  constructor( aPos, aDir, 4.0f )
end constructor

constructor Bullet( aPos as Vec2, aDir as Vec2, aSize as single )
  constructor( aPos, aDir, aSize, 2.0f, 100.0f )
end constructor

constructor Bullet( _
  aPos as Vec2, aDir as Vec2, _
  aSize as single, aSpeed as single, aLifetime as single )
  
  pos = aPos
  dir = aDir
  size = aSize
  speed = aSpeed
  lifetime = aLifetime
end constructor

destructor Bullet() : end destructor

'' Represents a group of bullets
type BulletManager
  declare constructor()
  declare constructor( as long )
  declare destructor()
  
  as Bullet bullets( any )
  as long bulletCount
end type

constructor BulletManager()
  constructor( 256 )
end constructor

constructor BulletManager( numBullets as long )
  redim bullets( 0 to numBullets - 1 )
  bulletCount = 0
end constructor

destructor BulletManager() : end destructor

'' Represents the global game state
type GameState
  declare constructor()
  declare constructor( as long, as long, as long )
  declare destructor()
  
  as BoundingBox playArea
  
  as Player players( any )
  as PlayerControls playerControls( any )
  as BulletManager bulletManagers( any )
  as Asteroid asteroids( any )
  
  as KeyboardInput keyboard
  
  as long _
    playerCount, _
    bulletManagerCount, _
    asteroidCount
  
  static as const long MAX_ASTEROIDS
end type

'' Maximum number of asteroids at the same time. If this number
'' is exceeded, the game would not spawn more asteroids.
dim as const long GameState.MAX_ASTEROIDS = 1000

constructor GameState()
  constructor( 1, 50, 1 )
end constructor

constructor GameState( _
  numPlayers as long, numAsteroids as long, numBulletManagers as long )
  
  playerCount = numPlayers
  asteroidCount = numAsteroids
  bulletManagerCount = numBulletManagers
  
  redim _
    players( 0 to playerCount - 1 ), _
    playerControls( 0 to playerCount - 1 ), _
    bulletManagers( 0 to bulletManagerCount ), _
    asteroids( 0 to MAX_ASTEROIDS - 1 )
end constructor

destructor GameState() : end destructor

'' Basic operations on data structures
sub add overload( bm as BulletManager, b as Bullet )
  if( bm.bulletCount <= ubound( bm.bullets ) ) then
    bm.bulletCount += 1
    bm.bullets( bm.bulletCount - 1 ) = b
  end if
end sub

sub remove overload( bm as BulletManager, id as long )
  bm.bullets( id ) = bm.bullets( bm.bulletCount - 1 )
  bm.bulletCount -= 1
end sub

sub move overload( sh as Ship, dt as double )
  if( sh.vel.lengthSq() > sh.maxSpeed ^ 2 ) then
    sh.vel = sh.vel.normalized() * sh.maxSpeed
  end if
  
  sh.pos += sh.vel * dt
end sub

sub accelerate( sh as Ship, a as Vec2 )
  sh.vel += a 
end sub

sub rotate( sh as Ship, a as single )
  sh.dir = sh.dir.rotated( toRad( a ) ).normalize()
end sub

sub shoot( state as GameState, sh as Ship, dt as double )
  '' Choose a random direction arc
  var bd = sh.dir.rotated( _
    toRad( rng( -5.0f, 5.0f ) ) ).normalize()
  
  '' Spawn the bullet in front of the player
  add( state.bulletManagers( 0 ), Bullet( _
    sh.pos + bd * sh.size, bd, _
    6.0f, 500.0f, 1000.0f ) )
  
  '' Add a little backwards acceleration to the player's ship
  '' when firing.
  accelerate( sh, -sh.dir.normalized() * 400.0f * dt )
end sub

sub move( a as Asteroid, dt as double )
  a.pos += a.vel * dt
end sub

'' Physics and collision detection and response
function getCollisionNormal( N as Vec2, v1 as Vec2, v2 as Vec2 ) as Vec2
  '' Compute tangent vector to normal and relative velocities
  '' of the collision.
  var _
    tangent = N.turnedRight().normalize(), _
    vRel = v1 - v2
  
  '' Compute length of the relative velocity projected on the
  '' tangent axis.
  dim as single l = vRel.dot( tangent )
  
  '' Decompose into normal and tangential velocities, and return
  '' the normal velocity.
  return( vRel - ( tangent * l ) )
end function

function resolveCollision( _
    bc1 as BoundingCircle, bc2 as BoundingCircle, vN as Vec2, vel1 as Vec2, vel2 as Vec2 ) _
  as Vec2
  
  '' Compute the Minimum Translation Vector to move the
  '' overlapping circles out of collision.
  var mtv = _
    -( ( bc1.center - bc2.center ) - ( bc1.center - bc2.center ).ofLength( _
         bc1.radius + bc2.radius ) )
    
  '' And reflect the velocities along the normal of
  '' the collision.
  vel1 -= vN
  vel2 += vN
  
  return( mtv )
end function

function asteroidsCollided( _
    a1 as BoundingCircle, a2 as BoundingCircle, vel1 as Vec2, vel2 as Vec2 ) _
  as Vec2
  
  '' Compute collision normal
  var vN = getCollisionNormal( ( a1.center - a2.center ), vel1, vel2 )
   
  '' Resolve the collision
  return( resolveCollision( a1, a2, vN, vel1, vel2 ) )
end function

function shipAndAsteroidCollided( _
    shbc as BoundingCircle, abc as BoundingCircle, vel1 as Vec2, vel2 as Vec2 ) _
  as Vec2
  
  '' Get collision normal
  var vN = getCollisionNormal( ( shbc.center - abc.center ), vel1, vel2 )
  
  '' Resolve ship-asteroid collision
  return( resolveCollision( shbc, abc, vN, vel1, vel2 ) )
end function

sub asteroidDestroyed( state as GameState, dt as double, asteroidId as long )
  with state
    var destroyed = .asteroids( asteroidId )
    
    .asteroids( asteroidId ) = .asteroids( .asteroidCount - 1 )
    .asteroidCount -= 1
    
    dim as single s = destroyed.size * 0.4f
    
    if( s >= 5.0f andAlso ( .asteroidCount + 4 ) < state.MAX_ASTEROIDS ) then
      .asteroidCount += 4
      
      for i as integer = 0 to 3
        .asteroids( .asteroidCount - 1 - i ) = Asteroid( _
          destroyed.pos, rndNormal() * ( 400.0f - s * 10.0f ), s )
      next
    end if
  end with
end sub

sub checkAsteroids( state as GameState, dt as double )
  var _
    b = BoundingCircle(), _
    a = BoundingCircle()
  
  var byref bm = state.bulletManagers( 0 )
  
  with state.bulletManagers( 0 )
    dim as long currentBullet = 0
    
    do while( currentBullet < .bulletCount )
      b.center = .bullets( currentBullet ).pos
      b.radius = .bullets( currentBullet ).size
      
      dim as long currentAsteroid = 0
      dim as boolean removed = false
      
      do while( currentAsteroid < state.asteroidCount )
        with state.asteroids( currentAsteroid )
          a.center = .pos
          a.radius = .size
          
          if( b.overlapsWith( a ) ) then
            asteroidDestroyed( state, dt, currentAsteroid )
            removed = true
            
            continue do
          end if
        end with
        
        currentAsteroid += 1
      loop
      
      if( removed ) then
        remove( state.bulletManagers( 0 ), currentBullet )
      else
        currentBullet += 1
      end if
    loop
  end with
end sub

'' Updating
sub updateAsteroids( state as GameState, dt as double )
  '' The two asteroid bounding circles
  var _
    a1 = BoundingCircle(), _
    a2 = BoundingCircle()
  
  for i as integer = 0 to state.asteroidCount - 1
    with state.asteroids( i )
      move( state.asteroids( i ), dt )
      
      a1.center = .pos
      a1.radius = .size
      
      for j as integer = i + 1 to state.asteroidCount - 1
        var byref another = state.asteroids( j )
        
        a2.center = another.pos
        a2.radius = another.size
        
        if( a1.overlapsWith( a2 ) ) then
          var mtv = asteroidsCollided( a1, a2, .vel, another.vel )
          
          '' Adjust the position of the asteroids
          .pos += mtv * 0.5f
          another.pos -= mtv * 0.5f
        end if
      next
      
      '' Wrap around the play area
      .pos = wrapV( .pos, _
        state.playArea.x, state.playArea.y, _
        state.playArea.width, state.playArea.height )
    end with
  next
end sub

sub updatePlayers( state as GameState, dt as double )
  '' Player and Asteroid bounding circles, respectively
  var _
    pbc = BoundingCircle(), _
    abc = BoundingCircle()
  
  for i as integer = 0 to state.playerCount - 1
    '' Shorthand vars
    var byref p = state.players( i )
    var byref sh = p.playerShip
    
    move( sh, dt )
    
    '' Center the bounding circle on the player's position
    pbc.center = sh.pos
    pbc.radius = 5
    
    with state.playerControls( i )
      dim as boolean strafing
      
      if( state.keyboard.held( .forward ) ) then
        accelerate( sh, sh.dir * sh.accel * dt )
      end if
      
      if( state.keyboard.held( .backward ) ) then
        accelerate( sh, sh.dir * -sh.accel * dt )
      end if
      
      if( state.keyboard.held( .strafe ) ) then
        strafing = true
      end if
      
      if( state.keyboard.held( .rotateLeft ) ) then
        if( strafing ) then
          accelerate( sh, sh.dir.turnedRight() * sh.accel * dt )
        else
          rotate( sh, -sh.turnSpeed * dt )
        end if
      end if
      
      if( state.keyboard.held( .rotateRight ) ) then
        if( strafing ) then
          accelerate( sh, sh.dir.turnedLeft() * sh.accel * dt )
        else
          rotate( sh, sh.turnSpeed * dt )
        end if
      end if
      
      if( state.keyboard.pressed( .fire ) ) then
        shoot( state, sh, dt )
      end if
      
      if( state.keyboard.repeated( .fire, sh.rateOfFire ) ) then
        shoot( state, sh, dt )
      end if
    end with
    
    '' Check collisions with asteroids
    for j as integer = 0 to state.asteroidCount - 1
      '' Center the bounding circle on the asteroid's position
      abc.center = state.asteroids( j ).pos
      abc.radius = state.asteroids( j ).size
      
      if( pbc.overlapsWith( abc ) ) then
        '' Get the normal for the collision
        var vN = getCollisionNormal( _
          ( pbc.center - abc.center ), sh.vel, state.asteroids( j ).vel )
        
        '' Resolve player-asteroid collision and retrieve the
        '' Minimum Translation Vector.
        var mtv = resolveCollision( pbc, abc, vN, sh.vel, state.asteroids( j ).vel )
        
        '' Update positions
        sh.pos += mtv * 0.5f
        state.asteroids( j ).pos -= mtv * 0.5f
        
        '' Damage the player in question. The damage taken will
        '' scale depending on the velocity of the collision and
        '' the size of the asteroid the player collided with.
        p.health -= vN.length * ( C_DAMAGE_SCALE * state.asteroids( j ).size )
      end if
    next
    
    '' Wrap around play area
    with state.playArea
      sh.pos = wrapV( sh.pos, .x, .y, .width, .height )
    end with
  next
end sub

sub updateBulletManager( state as GameState, bm as BulletManager, dt as double )
  dim as long current = 0
  
  do while( current < bm.bulletCount )
    var byref b = bm.bullets( current )
    
    b.pos += b.dir * b.speed * dt
    b.lifetime -= 1000.0f * dt
    
    if( b.lifetime <= 0.0f ) then
      remove( bm, current )
      continue do
    end if
    
    with state.playArea
      b.pos = wrapV( b.pos, .x, .y, .width, .height )
    end with
    
    current += 1
  loop
end sub

sub updateBulletManagers( state as GameState, dt as double )
  for i as integer = 0 to state.bulletManagerCount - 1
    updateBulletManager( state, state.bulletManagers( i ), dt )
  next
end sub

sub update( state as GameState, dt as double )
  updatePlayers( state, dt )
  updateAsteroids( state, dt )
  updateBulletManagers( state, dt )
  checkAsteroids( state, dt )
end sub

'' Rendering
sub renderTriangle( _
  x1 as long, y1 as long,_
  x2 as long, y2 as long, _
  x3 as long, y3 as long, _
  c as ulong, buffer as any ptr = 0 )
  
  if( y2 < y1 ) then swap y1, y2 : swap x1, x2 : end if
  if( y3 < y1 ) then swap y3, y1 : swap x3, x1 : end if
  if( y3 < y2 ) then swap y3, y2 : swap x3, x2 : end if
  
  dim as long _
    delta1 = iif( y2 - y1 <> 0, ( ( x2 - x1 ) shl 16 ) \ ( y2 - y1 ), 0 ), _
    delta2 = iif( y3 - y2 <> 0, ( ( x3 - x2 ) shl 16 ) \ ( y3 - y2 ), 0 ), _
    delta3 = iif( y1 - y3 <> 0, ( ( x1 - x3 ) shl 16 ) \ ( y1 - y3 ), 0 )
  
  '' Top half
  dim as long lx = x1 shl 16, rx = lx
  
  for y as integer = y1 to y2 - 1
    line buffer, ( lx shr 16, y ) - ( rx shr 16, y ), c 
    lx = lx + delta1 : rx = rx + delta3
  next
  
  '' Bottom half
  lx = x2 shl 16
  
  for y as integer = y2 to y3
    line buffer, ( lx shr 16, y ) - ( rx shr 16, y ), c 
    lx = lx + delta2 : rx = rx + delta3
  next
end sub

sub renderShip( s as Ship, c as ulong )
  var _
    p0 = s.pos + s.dir * s.size, _
    p1 = s.pos + s.dir.turnedLeft() * ( s.size * 0.5f ), _
    p2 = s.pos + s.dir.turnedRight() * ( s.size * 0.5f )
  
  renderTriangle( p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, c )
  circle( s.pos.x, s.pos.y ), 5, c, , , , f
end sub

sub renderAsteroids( state as GameState )
  for i as integer = 0 to state.asteroidCount - 1
    with state.asteroids( i )
      circle( .pos.x, .pos.y ), .size, .color, , , , f
    end with
  next
end sub

sub renderBullets( state as GameState )
  for i as integer = 0 to state.bulletManagers( 0 ).bulletCount - 1
    with state.bulletManagers( 0 ).bullets( i )
      var _
        p0 = .pos - ( .dir * 8 ), _
        p1 = .pos + ( .dir * 8 )
      
      line( p0.x, p0.y ) - ( p1.x, p1.y ), Colors.White
    end with
  next
end sub

sub renderPlayers( state as GameState )
  for i as integer = 0 to state.playerCount - 1
    renderShip( _
      state.players( i ).playerShip, _
      rgba( 255, 255, 0, 255 ) )
  next
end sub

sub render( state as GameState )
  cls()
    renderPlayers( state )
    renderAsteroids( state )
    renderBullets( state )
    ? "Health: " & int( state.players( 0 ).health )
  flip()
end sub

'' Initialization
function init( xRes as long, yRes as long ) as BoundingBox
  randomize()
  screenRes( xRes, yRes, 32, 2 )
  screenSet( 0, 1 )
  
  return( BoundingBox( -20, -20, xRes + 20, yRes + 20 ) )
end function

sub initState( s as GameState )
  with s
    .players( 0 ) = Player( _
      Ship( Vec2( _
        ( .playArea.width - .playArea.x ) / 2, _
        ( .playArea.height - .playArea.y ) / 2 ), _
      20.0f ) )
    
    with .players( 0 )
      .playerShip.maxSpeed = 300.0f
      .playerShip.rateOfFire = 50.0f
    end with
    
    .playerControls( 0 ) = type <PlayerControls>( _
      Fb.SC_UP, Fb.SC_DOWN, Fb.SC_LEFT, Fb.SC_RIGHT, Fb.SC_SPACE, Fb.SC_LSHIFT )
    
    for i as integer = 0 to .asteroidCount - 1
      dim as single size = rng( 8.0f, 40.0f )
      
      .asteroids( i ) = Asteroid( _
        rngWithin( .playArea ), _
        Vec2( rng( -1.0f, 1.0f ), rng( -1.0f, 1.0f ) ) * ( 200.0f - size * 5.0f ), _
        size )
    next
  end with
end sub

'' Main code, at last!
var state = GameState( 1, 30, 2 )
state.playArea = init( 800, 600 )

initState( state )

dim as boolean done = false
dim as double dt, fps

dim as Fb.Event e

do
  '' Update
  do while( screenEvent( @e ) )
    state.keyboard.onEvent( @e )
    
    if( e.type = Fb.EVENT_WINDOW_CLOSE ) then
      done = true
    end if
  loop
  
  update( state, dt )
  
  '' Render
  dt = timer()
    render( state )
    sleep( 1, 1 )
  dt = timer() - dt
  
  fps = 1.0f / dt
loop until( done )
