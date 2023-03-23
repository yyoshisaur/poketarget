# poketarget

NPCに話しかけるアドオン poketarget

アドオンがロードされているすべてのキャラクターが対象

NPCをターゲットしている状態で話しかける（このコマンド実行したキャラクターのみ）

    //poketarget or //pta

このコマンドを実行したキャラクターがターゲットしているNPCに話しかける
（自分を含め同一PC内のキャラクターすべてで）

    //poketarget a

自分を含め同一PC内のパーティ中のキャラクターすべてで話しかける

    //poketarget p

NPCのIDを指定して話しかける

    //poketarget 123456

同一PC上のキャラクターすべてで指定したIDのNPCに話しかける

    //poketarget a 123456

同一PC上の同じパーティ内キャラクターで指定したIDのNPCに話しかける

    //poketarget p 123456

aはall/@allでも可能
pはparty/@partyでも可能

all/partyのオプションを指定した場合、キーボードの上下左右キー、エンターキー、エスケープキーの入力を他のキャラクターも同期して行う

## ライブラリ
sendall.lua

Copyright (c) 2019, Akaden of Asura

https://github.com/AkadenTK/superwarp/blob/master/sendall.lua

