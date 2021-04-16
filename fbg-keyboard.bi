#ifndef __FBGAME_KEYBOARD__
#define __FBGAME_KEYBOARD__

#include once "fbgfx.bi"

namespace FbGame
  type KeyboardInput
    public:
      declare constructor()
      declare constructor( as integer )
      declare destructor()
      
      declare sub onEvent( as any ptr )
      
      declare function pressed( as long ) as boolean
      declare function released(as long ) as boolean
      declare function held( as long, as double = 0.0 ) as boolean
      declare function repeated( as long, as double = 0.0 ) as boolean
    
    private:
      enum KeyState
        None
        Pressed             = ( 1 shl 0 )
        AlreadyPressed      = ( 1 shl 1 )
        Released            = ( 1 shl 2 )
        AlreadyReleased     = ( 1 shl 3 )
        Held                = ( 1 shl 4 )
        HeldInitialized     = ( 1 shl 5 )
        Repeated            = ( 1 shl 6 )
        RepeatedInitialized = ( 1 shl 7 )
      end enum
      
      '' These will store the bitflags for the key states
      as ubyte _state( any )
      
      /'
        Caches when a key started being held/repeated
      '/
      as double _
        _heldStartTime( any ), _
        _repeatedStartTime( any )
      
      /'
        The mutex for this instance
      '/
      as any ptr _mutex
  end type
  
  constructor KeyboardInput()
    this.constructor( 128 )
  end constructor
  
  constructor KeyboardInput( aNumberOfKeys as integer )
    dim as integer keys = iif( aNumberOfKeys < 128, 128, aNumberOfKeys )
    
    redim _
      _state( 0 to keys - 1 ), _
      _heldStartTime( 0 to keys - 1 ), _
      _repeatedStartTime( 0 to keys - 1 )
    
    _mutex = mutexCreate()
  end constructor
  
  destructor KeyboardInput()
    mutexDestroy( _mutex )
  end destructor
  
  sub KeyboardInput.onEvent( e as any ptr )
    mutexLock( _mutex )
      var ev = cptr( Fb.Event ptr, e )
      
      select case as const( ev->type )
        case Fb.EVENT_KEY_PRESS
          _state( ev->scanCode ) or= _
            ( KeyState.Pressed or KeyState.Held or KeyState.Repeated )
          _state( ev->scanCode ) = _
            _state( ev->scanCode ) and not KeyState.AlreadyPressed
          
        case Fb.EVENT_KEY_RELEASE
          _state( ev->scanCode ) or= KeyState.Released
          _state( ev->scanCode ) = _
            _state( ev->scanCode ) and not KeyState.AlreadyReleased
          _state( ev->scanCode ) = _state( ev->scanCode ) and not _
            ( KeyState.Held or KeyState.HeldInitialized or _
              KeyState.Repeated or KeyState.RepeatedInitialized )
      end select
    mutexUnlock( _mutex )
  end sub
  
  /'
    Returns whether or not a key was pressed.
    
    'Pressed' in this context means that the method will return 'true'
    *once* upon a key press. If you press and hold the key, it will
    not report 'true' until you release the key and press it again.
  '/
  function KeyboardInput.pressed( scanCode as long ) as boolean
    mutexLock( _mutex )
      dim as boolean isPressed
      
      if( _
        cbool( _state( scanCode ) and KeyState.Pressed ) andAlso _
        not cbool( _state( scanCode ) and KeyState.AlreadyPressed ) ) then
        
        isPressed = true
        
        _state( scanCode ) or= KeyState.AlreadyPressed
      end if
    mutexUnlock( _mutex )
    
    return( isPressed )
  end function
  
  /'
    Returns whether or not a key was released.
    
    'Released' means that a key has to be pressed and then released for
    this method to return 'true' once, just like the 'pressed()' method
    above.
  '/
  function KeyboardInput.released( scanCode as long ) as boolean
    mutexLock( _mutex )
      dim as boolean isReleased
      
      if( _
        cbool( _state( scanCode ) and KeyState.Released ) andAlso _
        not cbool( _state( scanCode ) and KeyState.AlreadyReleased ) ) then
        
        isReleased = true
        
        _state( scanCode ) or= KeyState.AlreadyReleased
      end if
    mutexUnlock( _mutex )
    
    return( isReleased )
  end function
  
  /'
    Returns whether or not a key is being held.
    
    'Held' means that the key was pressed and is being held pressed, so the
    method behaves pretty much like a call to 'multiKey()', if the 'interval'
    parameter is unspecified.
    
    If an interval is indeed specified, then the method will report the 'held'
    status up to the specified interval, then it will stop reporting 'true'
    until the key is released and held again.
    
    Both this and the 'released()' method expect their intervals to be expressed
    in milliseconds.
  '/
  function KeyboardInput.held( scanCode as long, interval as double = 0.0 ) as boolean
    mutexLock( _mutex )
      dim as boolean isHeld
      
      if( cbool( _state( scanCode ) and KeyState.Held ) ) then
        isHeld = true
        
        if( cbool( interval > 0.0 ) ) then
          if( not cbool( _state( scanCode ) and KeyState.HeldInitialized ) ) then
            _state( scanCode ) or= KeyState.HeldInitialized
            _heldStartTime( scanCode ) = timer()
          else
            dim as double _
              elapsed = ( timer() - _heldStartTime( scanCode ) ) * 1000.0d
            
            if( elapsed >= interval ) then
              isHeld = false
              
              _state( scanCode ) = _state( scanCode ) and not KeyState.Held
            end if
          end if
        end if
      end if
    mutexUnlock( _mutex )
    
    return( isHeld )
  end function
  
  /'
    Returns whether or not a key is being repeated.
    
    'Repeated' means that the method will intermittently report the 'true'
    status once 'interval' milliseconds have passed. It can be understood
    as the autofire functionality of some game controllers: you specify the
    speed of the repetition using the 'interval' parameter.
    
    Bear in mind, however, that the *first* repetition will be reported
    AFTER one interval has elapsed. In other words, the reported pattern is 
    [pause] [repeat] [pause] instead of [repeat] [pause] [repeat].
    
    If no interval is specified, the method behaves like a call to
    'held()'.
  '/
  function KeyboardInput.repeated( scanCode as long, interval as double = 0.0 ) as boolean
    mutexLock( _mutex )
      dim as boolean isRepeated
      
      if( cbool( _state( scanCode ) and KeyState.Repeated ) ) then
        if( cbool( interval > 0.0 ) ) then
          if( not cbool( _state( scanCode ) and KeyState.RepeatedInitialized ) ) then
            _repeatedStartTime( scanCode ) = timer()
            _state( scanCode ) or= KeyState.RepeatedInitialized
          else
            dim as double _
              elapsed = ( timer() - _repeatedStartTime( scanCode ) ) * 1000.0d
            
            if( elapsed >= interval ) then
              isRepeated = true
              
              _state( scanCode ) = _
                _state( scanCode ) and not KeyState.RepeatedInitialized
            end if
          end if
        else
          isRepeated = true
        end if
      end if
    mutexUnlock( _mutex )
    
    return( isRepeated )
  end function
end namespace

#endif
