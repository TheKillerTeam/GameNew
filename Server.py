from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
from twisted.internet.task import LoopingCall
from time import time
from struct import *

MESSAGE_PLAYER_CONNECTED = 0
MESSAGE_NOT_IN_MATCH = 1
MESSAGE_START_MATCH = 2
MESSAGE_MATCH_STARTED = 3
MESSAGE_PLAYER_IMAGE_UPDATED = 4
MESSAGE_PLAYER_SEND_CHAT = 5
MESSAGE_UPDATE_CHAT = 6
MESSAGE_PLAYER_VOTE_FOR = 7
MESSAGE_UPDATE_VOTE = 8

MATCH_STATE_ACTIVE = 0
MATCH_STATE_GAME_OVER = 1

CHAT_TO_ALL = 0
CHAT_TO_TEAM = 1

PLAYER_STATE_ONE = 0

PLAYER_TEAM_ONE = 1

SECS_FOR_SHUTDOWN = 5

class MessageReader:

    def __init__(self, data):
        self.data = data
        self.offset = 0

    def readByte(self):
        retval = unpack('!B', self.data[self.offset:self.offset+1])[0]
        self.offset = self.offset + 1
        return retval

    def readInt(self):
        retval = unpack('!I', self.data[self.offset:self.offset+4])[0]
        self.offset = self.offset + 4
        return retval

    def readString(self):
        strLength = self.readInt()
        unpackStr = '!%ds' % (strLength)
        retval = unpack(unpackStr, self.data[self.offset:self.offset+strLength])[0]
        self.offset = self.offset + strLength
        return retval

class MessageWriter:

    def __init__(self):
        self.data = ""

    def writeByte(self, value):        
        self.data = self.data + pack('!B', value)

    def writeInt(self, value):
        self.data = self.data + pack('!I', value)

    def writeString(self, value):
        self.writeInt(len(value))
        packStr = '!%ds' % (len(value))
        self.data = self.data + pack(packStr, value)

class GameMatch:

    def __init__(self, players):
        self.players = players
        self.state = MATCH_STATE_ACTIVE
        self.pendingShutdown = False
        self.shutdownTime = 0
        self.timer = LoopingCall(self.update)
        self.timer.start(5)

    def __repr__(self):
        return "%d %s" % (self.state, str(self.players))

    def write(self, message):
        message.writeByte(self.state)
        message.writeByte(len(self.players))
        for matchPlayer in self.players:
            matchPlayer.write(message)

    def update(self):
        print "Match update: %s" % (str(self))
        if (self.pendingShutdown):
            cancelShutdown = True
            for player in self.players:
                if player.protocol == None:
                    cancelShutdown  =False
            if (time() > self.shutdownTime):
                print "Time elapsed, shutting down match"
                self.quit()
        else:
            for player in self.players:
                if player.protocol == None:
                    print "Player %s disconnected, scheduling shutdown" % (player.alias)
                    self.pendingShutdown = True
                    self.shutdownTime = time() + SECS_FOR_SHUTDOWN

    def quit(self):
        self.timer.stop()
        for matchPlayer in self.players:
            matchPlayer.match = None
            if matchPlayer.protocol:
                matchPlayer.protocol.sendNotInMatch()    

class GamePlayer:

    def __init__(self, protocol, playerImage, playerId, alias):
        self.protocol = protocol
        self.playerImage = playerImage
        self.playerId = playerId
        self.alias = alias
        self.match = None
        self.playerState = PLAYER_STATE_ONE
        self.playerTeam = PLAYER_TEAM_ONE
        self.voteFor = 99

    def __repr__(self):
        return "%s:%d,%d,%d" % (self.alias, self.playerState, self.playerTeam, self.voteFor)

    def write(self, message):
        message.writeString(self.playerImage)
        message.writeString(self.playerId)
        message.writeString(self.alias)
        message.writeByte(self.playerState)
        message.writeByte(self.playerTeam)

    def startMatch(self, playerIds):
        matchPlayers = []
        for existingPlayer in self.players:
            if existingPlayer.playerId in playerIds:
                if existingPlayer.match != None:
                    return
                matchPlayers.append(existingPlayer)
        match = GameMatch(matchPlayers)
        for matchPlayer in matchPlayers:
            matchPlayer.match = match
            matchPlayer.protocol.sendMatchStarted(match)

class GameFactory(Factory):

    def __init__(self):
        self.protocol = GameProtocol
        self.players = []

    def connectionLost(self, protocol):
        for existingPlayer in self.players:
            if existingPlayer.protocol == protocol:
                existingPlayer.protocol = None

    def playerConnected(self, protocol, playerImage, playerId, alias, continueMatch):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.playerImage = playerImage
                existingPlayer.alias = alias
                existingPlayer.continueMatch = continueMatch
                existingPlayer.protocol = protocol
                protocol.player = existingPlayer
                if (existingPlayer.match):
                    print "TODO: Already in match case update match,state,team,vote"
                else:
                    existingPlayer.protocol.sendNotInMatch()
                return
        newPlayer = GamePlayer(protocol, playerImage, playerId, alias)
        protocol.player = newPlayer
        self.players.append(newPlayer)
        newPlayer.protocol.sendNotInMatch()

    def playerImageUpdated(self, protocol, playerImage, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.playerImage = playerImage
       
    def playerSendChat(self, protocol, chat, chatType, playerId):
        if chatType == CHAT_TO_ALL:
            for existingPlayer in self.players:
                if existingPlayer.playerId != playerId:
                    existingPlayer.protocol.sendUpdateChat(chat,playerId)
        if chatType == CHAT_TO_TEAM:
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in self.players:
                        if player.playerTeam == existingPlayer.playerTeam:
                            if player.playerId != playerId:
                                existingPlayer.protocol.sendUpdateChat(chat,playerId)  
                                
    def playerVoteFor(self, protocol, voteFor, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                votedFor = existingPlayer.voteFor
                if existingPlayer.voteFor == voteFor:
                    existingPlayer.voteFor = 99
                else:
                    existingPlayer.voteFor = voteFor
        for existingPlayer in self.players:
            if existingPlayer.playerId != playerId:
                existingPlayer.protocol.sendUpdateVote(voteFor, votedFor, playerId)

    def startMatch(self, playerIds):
        matchPlayers = []
        for existingPlayer in self.players:
            if existingPlayer.playerId in playerIds:
                if existingPlayer.match != None:
                    return
                matchPlayers.append(existingPlayer)
        match = GameMatch(matchPlayers)
        for matchPlayer in matchPlayers:
            matchPlayer.match = match
            matchPlayer.playerState = PLAYER_STATE_ONE
            matchPlayer.playerTeam = PLAYER_TEAM_ONE
            matchPlayer.voteFor = 99
            matchPlayer.protocol.sendMatchStarted(match)

class GameProtocol(Protocol):

    def __init__(self):
        self.inBuffer = ""
        self.player = None

    def log(self, message):
        if (self.player):
            print "%s: %s" % (self.player.alias, message)
        else:
            print "%s: %s" % (self, message)

    def connectionMade(self):
        self.log("Connection made")

    def connectionLost(self, reason):
        self.log("Connection lost: %s" % str(reason))
        self.factory.connectionLost(self)

    def sendMessage(self, message):
        msgLen = pack('!I', len(message.data))
        self.transport.write(msgLen)
        self.transport.write(message.data)

    def sendNotInMatch(self):
        message = MessageWriter()
        message.writeByte(MESSAGE_NOT_IN_MATCH)
        self.log("Sent MESSAGE_NOT_IN_MATCH")
        self.sendMessage(message)

    def sendMatchStarted(self, match):
        message = MessageWriter()
        message.writeByte(MESSAGE_MATCH_STARTED)
        match.write(message)
        self.log("Sent MATCH_STARTED %s" % (str(match)))
        self.sendMessage(message)

    def startMatch(self, message):
        numPlayers = message.readByte()
        playerIds = []
        for i in range(0, numPlayers):
            playerId = message.readString()
            playerIds.append(playerId)
        self.log("Recv MESSAGE_START_MATCH %s" % (str(playerIds)))
        self.factory.startMatch(playerIds)

    def playerConnected(self, message):
        playerImage = message.readString()
        playerId = message.readString()
        alias = message.readString()
        continueMatch = message.readByte()
        self.log("Recv MESSAGE_PLAYER_CONNECTED %s %s %d" % (playerId, alias, continueMatch))
        self.factory.playerConnected(self, playerImage, playerId, alias, continueMatch)

    def playerImageUpdated(self, message):
        playerImage = message.readString()
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_IMAGE_UPDATED %s" % (playerId))
        self.factory.playerImageUpdated(self, playerImage, playerId)
        
    def playerSendChat(self, message):
        chat = message.readString()
        chatType = message.readByte()
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_SEND_CHAT %s %s %d" % (playerId, chat, chatType))
        self.factory.playerSendChat(self, chat, chatType, playerId)
        
    def sendUpdateChat(self, chat, playerId):
        message = MessageWriter()
        message.writeByte(MESSAGE_UPDATE_CHAT)
        message.writeString(chat)
        message.writeString(playerId)
        self.log("Sent MESSAGE_UPDATE_CHAT")
        self.sendMessage(message)
        
    def sendUpdateVote(self, voteFor, votedFor, playerId):
        message = MessageWriter()
        message.writeByte(MESSAGE_UPDATE_VOTE)
        message.writeByte(voteFor)
        message.writeByte(votedFor)
        message.writeString(playerId)
        self.log("Sent MESSAGE_UPDATE_VOTE")
        self.sendMessage(message)

    def playerVoteFor(self, message):
        voteFor = message.readByte()
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_VOTE_FOR %s %d" % (playerId, voteFor))
        self.factory.playerVoteFor(self, voteFor, playerId)
        
    def processMessage(self, message):
        messageId = message.readByte()
        if messageId == MESSAGE_PLAYER_CONNECTED:
            return self.playerConnected(message)
        if messageId == MESSAGE_START_MATCH:
            return self.startMatch(message)
        if messageId == MESSAGE_PLAYER_IMAGE_UPDATED:
            return self.playerImageUpdated(message)
        if messageId == MESSAGE_PLAYER_SEND_CHAT:
            return self.playerSendChat(message)
        if messageId == MESSAGE_PLAYER_VOTE_FOR:
            return self.playerVoteFor(message)
        self.log("Unexpected message: %d" % (messageId))

    def dataReceived(self, data):
        self.inBuffer = self.inBuffer + data
        while(True):
            if (len(self.inBuffer) < 4):
                return;
            msgLen = unpack('!I', self.inBuffer[:4])[0]
            if (len(self.inBuffer) < msgLen):
                return;
            messageString = self.inBuffer[4:msgLen+4]
            self.inBuffer = self.inBuffer[msgLen+4:]
            message = MessageReader(messageString)
            self.processMessage(message)

factory = GameFactory()
reactor.listenTCP(1955, factory)
print "Game server started"
reactor.run()