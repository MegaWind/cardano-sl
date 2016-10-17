{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE UndecidableInstances #-}

-- | Acid-state wrapped operations.

module Pos.State.Acidic
       ( DiskState
       , closeState
       , openState
       , openMemState
       , tidyState

       , query
       , update

       , GetLeaders (..)
       , GetBlock (..)
       , MayBlockBeUseful (..)

       , AddTx (..)
       , ProcessBlock (..)
       , ProcessNewSlot (..)
       , ProcessOpening (..)
       , ProcessCommitment (..)
       ) where

import           Data.Acid          (EventResult, EventState, QueryEvent, UpdateEvent,
                                     makeAcidic)
import           Data.Default       (def)
import           Serokell.AcidState (ExtendedState, closeExtendedState,
                                     openLocalExtendedState, openMemoryExtendedState,
                                     queryExtended, tidyExtendedState, updateExtended)
import           Universum

import           Pos.State.Storage  (Storage)
import qualified Pos.State.Storage  as S

----------------------------------------------------------------------------
-- Acid-state things
----------------------------------------------------------------------------

type DiskState = ExtendedState Storage

query
    :: (EventState event ~ Storage, QueryEvent event, MonadIO m)
    => DiskState -> event -> m (EventResult event)
query = queryExtended

update
    :: (EventState event ~ Storage, UpdateEvent event, MonadIO m)
    => DiskState -> event -> m (EventResult event)
update = updateExtended

openState :: MonadIO m => Bool -> FilePath -> m DiskState
openState deleteIfExists fp = openLocalExtendedState deleteIfExists fp def

openMemState :: MonadIO m => m DiskState
openMemState = openMemoryExtendedState def

closeState :: MonadIO m => DiskState -> m ()
closeState = closeExtendedState

tidyState :: MonadIO m => DiskState -> m ()
tidyState = tidyExtendedState

makeAcidic ''Storage
    [ 'S.getLeaders
    , 'S.getBlock
    , 'S.mayBlockBeUseful
    , 'S.addTx
    , 'S.processBlock
    , 'S.processNewSlot
    , 'S.processOpening
    , 'S.processCommitment
    ]
