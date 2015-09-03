from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
from twisted.internet.task import LoopingCall
from time import time
from struct import *
import random

MESSAGE_PLAYER_CONNECTED = 0
MESSAGE_NOT_IN_MATCH = 1
MESSAGE_START_MATCH = 2
MESSAGE_MATCH_STARTED = 3
MESSAGE_PLAYER_IMAGE_UPDATED = 4
MESSAGE_PLAYER_ALIAS_UPDATED = 5
MESSAGE_PLAYER_SEND_CHAT = 6
MESSAGE_UPDATE_CHAT = 7
MESSAGE_PLAYER_VOTE_FOR = 8
MESSAGE_PLAYER_JUDGE_FOR = 9
MESSAGE_UPDATE_VOTE = 10
MESSAGE_UPDATE_JUDGE = 11
MESSAGE_START_DISCUSSION = 12
MESSAGE_RESET_VOTE = 13
MESSAGE_ALLOW_VOTE = 14
MESSAGE_PLAYER_NIGHT_CONFIRM_VOTE = 15
MESSAGE_PLAYER_DAY_CONFIRM_VOTE = 16
MESSAGE_PLAYER_JUDGEMENT_CONFIRM_VOTE = 17
MESSAGE_PLAYER_DIED = 18
MESSAGE_JUDGE_PLAYER = 19
MESSAGE_PLAYER_SEND_LAST_WORDS = 20
MESSAGE_PLAYER_HAS_LAST_WORDS = 21
MESSAGE_PLAYER_DISCONNECTED = 22
MESSAGE_GAME_OVER = 23
MESSAGE_NOTIFY_READY = 24

MATCH_STATE_ACTIVE = 0
MATCH_STATE_GAME_OVER = 1

CHAT_TO_ALL = 0
CHAT_TO_TEAM = 1
CHAT_TO_DEAD = 2

PLAYER_STATE_ALIVE = 0
PLAYER_STATE_DEAD = 1

PLAYER_TEAM_CIVILIAN = 0
PLAYER_TEAM_SHERIFF = 1
PLAYER_TEAM_MAFIA = 2

TEAM_LIST = []
TEAM_LIST.append([0,0,0])#0
TEAM_LIST.append([0,0,1])#1
TEAM_LIST.append([0,1,1])#2
TEAM_LIST.append([1,1,1])#3
TEAM_LIST.append([2,1,1])#4
TEAM_LIST.append([3,1,1])#5
TEAM_LIST.append([4,1,1])#6
TEAM_LIST.append([5,1,1])#7
TEAM_LIST.append([6,1,1])#8
TEAM_LIST.append([5,2,2])#9
TEAM_LIST.append([6,2,2])#10
TEAM_LIST.append([7,2,2])#11
TEAM_LIST.append([6,3,3])#12
TEAM_LIST.append([7,3,3])#13
TEAM_LIST.append([8,3,3])#14
TEAM_LIST.append([7,4,4])#15
TEAM_LIST.append([8,4,4])#16

SECS_FOR_GAMEOVER_SHUTDOWN = 70

UNRESETED = 0
RESETED = 1

NOTCONFIRMED = 0
CONFIRMED = 1

JUDGE_GUILTY = 0
JUDGE_INNOCENT = 1

NOT_OVER_YET = 0
MAFIA_WIN = 1
CIVILIAN_WIN = 2

NOT_SHUTTING_DOWN = 0
SHUTTING_DOWN = 1

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
        self.quitting = False
        self.pendingShutdown = False
        self.shutdownTime = 0
        self.timer = LoopingCall(self.update)
        self.timer.start(3)

    def __repr__(self):
        return "%d %s" % (self.state, str(self.players))

    def write(self, message):
        message.writeByte(self.state)
        message.writeByte(len(self.players))
        for matchPlayer in self.players:
            matchPlayer.write(message)

    def update(self):
        print "Match update: %s" % (str(self))
        playerDisconnected = []
        for player in self.players:
            if player.protocol == None:
                playerDisconnected.append(player)
                if self.state == MATCH_STATE_ACTIVE:
                    if player.playerState == PLAYER_STATE_ALIVE:
                        for p in self.players:
                            if (p.protocol):
                                p.protocol.sendPlayerDisconnected(player.playerId, SHUTTING_DOWN)
                        self.quitting = True
                    else:
                        for p in self.players:
                            if (p.protocol):
                                p.protocol.sendPlayerDisconnected(player.playerId, NOT_SHUTTING_DOWN)
                else:
                    for p in self.players:
                        if (p.protocol):
                            p.protocol.sendPlayerDisconnected(player.playerId, NOT_SHUTTING_DOWN)
        if (len(playerDisconnected) != 0):
            for player in playerDisconnected:
                print "Player %s disconnected" % (player.alias)
                player.match = None
                self.players.remove(player)
            playerDisconnected = []
        if (self.pendingShutdown == True):
            print "Shutdown countdown: %d" % (self.shutdownTime - time())
            if (time() > self.shutdownTime):
                self.quitting = True
        if (len(self.players) == 0):
            self.quitting = True
        if (self.quitting == True):
            self.quit()
            
    def quit(self):
        if self.timer.running:
            print "Match shut down "
            self.timer.stop()
        for matchPlayer in self.players:
            matchPlayer.match = None
            if matchPlayer.protocol:
                matchPlayer.protocol.sendNotInMatch()    

class GamePlayer:

    def __init__(self, protocol, playerImage, playerHeadImage, playerId, alias):
        self.protocol = protocol
        self.playerImage = playerImage
        self.playerHeadImage = playerHeadImage
        self.playerId = playerId
        self.alias = alias
        self.match = None
        self.playerState = PLAYER_STATE_ALIVE
        self.playerTeam = PLAYER_TEAM_CIVILIAN
        self.voteFor = 99
        self.beingJudged = 0
        self.judgeFor = 99
        self.voteCount = 0
        self.reseted = RESETED
        self.confirmVote = NOTCONFIRMED

    def __repr__(self):
        return "%s:s%d,t%d,vf%d,bj%d,jf%d,vc%d" % (self.alias, self.playerState, self.playerTeam, self.voteFor, self.beingJudged, self.judgeFor, self.voteCount)

    def write(self, message):
        message.writeString(self.playerImage)
        message.writeString(self.playerHeadImage)
        message.writeString(self.playerId)
        message.writeString(self.alias)
        message.writeByte(self.playerState)
        message.writeByte(self.playerTeam)

class GameFactory(Factory):

    def __init__(self):
        self.protocol = GameProtocol
        self.players = []

    def connectionLost(self, protocol):
        for existingPlayer in self.players:
            if existingPlayer.protocol == protocol:
                existingPlayer.protocol = None

    def playerConnected(self, protocol, playerImage, playerHeadImage, playerId, alias):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.playerImage = playerImage
                existingPlayer.playerHeadImage = playerHeadImage
                existingPlayer.alias = alias
                existingPlayer.match = None
                existingPlayer.protocol = protocol
                protocol.player = existingPlayer
                existingPlayer.protocol.sendNotInMatch()
                return
        newPlayer = GamePlayer(protocol, playerImage, playerHeadImage, playerId, alias)
        protocol.player = newPlayer
        self.players.append(newPlayer)
        newPlayer.protocol.sendNotInMatch()

    def playerImageUpdated(self, protocol, playerImage, playerHeadImage, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.playerImage = playerImage
                existingPlayer.playerHeadImage = playerHeadImage
                break
            
    def playerAliasUpdated(self, protocol, playerAlias, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.alias = playerAlias
                break
       
    def playerSendChat(self, protocol, chat, chatType, playerId):
        if chatType == CHAT_TO_ALL:
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:            
                    for player in existingPlayer.match.players:
                        if player.playerId != playerId:
                            player.protocol.sendUpdateChat(chat,playerId)
                    break
        if chatType == CHAT_TO_TEAM:
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        if player.playerTeam == existingPlayer.playerTeam:
                            if player.playerId != playerId:
                                if player.playerState == PLAYER_STATE_ALIVE:
                                    player.protocol.sendUpdateChat(chat,playerId)
                    break
        if chatType == CHAT_TO_DEAD:
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:              
                    for player in existingPlayer.match.players:
                        if player.playerState == PLAYER_STATE_DEAD:
                            if player.playerId != playerId:
                                player.protocol.sendUpdateChat(chat,playerId)
                    break
                
    def playerVoteFor(self, protocol, voteFor, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                votedFor = existingPlayer.voteFor
                if votedFor == voteFor:
                    existingPlayer.voteFor = 99
                    existingPlayer.match.players[voteFor].voteCount = existingPlayer.match.players[voteFor].voteCount - 1
                else:
                    existingPlayer.match.players[voteFor].voteCount = existingPlayer.match.players[voteFor].voteCount + 1
                    if votedFor != 99:
                        existingPlayer.match.players[existingPlayer.voteFor].voteCount = existingPlayer.match.players[existingPlayer.voteFor].voteCount - 1
                    existingPlayer.voteFor = voteFor
                break
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                for player in existingPlayer.match.players:
                    if player.playerId != playerId:
                        player.protocol.sendUpdateVote(voteFor, votedFor, playerId)
                break
                
    def playerJudgeFor(self, protocol, judgeFor, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                judgedFor = existingPlayer.judgeFor
                if judgedFor == judgeFor:
                    existingPlayer.judgeFor = 99
                else:
                    existingPlayer.judgeFor = judgeFor
                break
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:            
                for player in existingPlayer.match.players:
                    if player.playerId != playerId:
                        player.protocol.sendUpdateJudge(judgeFor, judgedFor, playerId)
                break

    def startDiscussion(self, protocol, playerId):
        allReseted = True;
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                for player in existingPlayer.match.players:
                    if player.reseted == UNRESETED:
                        allReseted = False;
                break
        if allReseted == True:
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        player.reseted = UNRESETED
                    break

    def resetVote(self, protocol, playerId):
        allReseted = True
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.voteFor = 99
                existingPlayer.judgeFor = 99
                existingPlayer.voteCount = 0
                existingPlayer.confirmVote = NOTCONFIRMED
                existingPlayer.reseted = RESETED
                for player in existingPlayer.match.players:
                    if player.reseted == UNRESETED:
                        allReseted = False                
                break
        if allReseted == True:
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        player.protocol.sendAllowVote()
                    break

    def playerNightConfirmVote(self, protocol, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.confirmVote = CONFIRMED
                break
        allConfirmed = True;
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                for player in existingPlayer.match.players:
                    if player.playerState == PLAYER_STATE_ALIVE:
                        if player.playerTeam == PLAYER_TEAM_MAFIA:
                            if player.confirmVote == NOTCONFIRMED:
                                allConfirmed = False
                        if player.playerTeam == PLAYER_TEAM_SHERIFF:
                            if player.confirmVote == NOTCONFIRMED:
                                allConfirmed = False
                break
        if allConfirmed == True:
            mafiaCount = 0
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        if player.playerTeam == PLAYER_TEAM_MAFIA:
                            if player.playerState == PLAYER_STATE_ALIVE:
                                mafiaCount += 1
                    break
            noOneDied = True
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        if player.voteCount *2 >= mafiaCount:
                            equalsToOtherPlayer = False;
                            for p in existingPlayer.match.players:
                                if p.playerId != player.playerId:
                                    if p.voteCount == player.voteCount:
                                        equalsToOtherPlayer = True;
                            if equalsToOtherPlayer == False:
                                player.playerState = PLAYER_STATE_DEAD
                                noOneDied = False
                                for p in existingPlayer.match.players:
                                    p.protocol.sendPlayerDied(player.playerId)
                            break
                    break
            if noOneDied == True:
                for existingPlayer in self.players:
                    if existingPlayer.playerId == playerId:
                        for player in existingPlayer.match.players:
                            player.protocol.sendPlayerDied("noOne")
                            player.protocol.sendGameOver(NOT_OVER_YET)
            else:
                alivePlayerCount = 0
                aliveMafiaCount = 0
                for existingPlayer in self.players:
                    if existingPlayer.playerId == playerId:
                        for player in existingPlayer.match.players:
                            if player.playerState == PLAYER_STATE_ALIVE:
                                alivePlayerCount += 1
                                if player.playerTeam == PLAYER_TEAM_MAFIA:
                                    aliveMafiaCount += 1
                        break
                if aliveMafiaCount == 0:
                    for existingPlayer in self.players:
                        if existingPlayer.playerId == playerId:
                            for player in existingPlayer.match.players:
                                player.protocol.sendGameOver(CIVILIAN_WIN)
                                player.match.state = MATCH_STATE_GAME_OVER
                            break
                else:
                    if aliveMafiaCount *2 >= alivePlayerCount:
                        for existingPlayer in self.players:
                            if existingPlayer.playerId == playerId:
                                for player in existingPlayer.match.players:
                                    player.protocol.sendGameOver(MAFIA_WIN)
                                    player.match.state = MATCH_STATE_GAME_OVER
                                break
                    else:
                        for existingPlayer in self.players:
                            if existingPlayer.playerId == playerId:
                                for player in existingPlayer.match.players:
                                    player.protocol.sendGameOver(NOT_OVER_YET)
                                break

    def playerDayConfirmVote(self, protocol, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.confirmVote = CONFIRMED
                break
        allConfirmed = True;
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                for player in existingPlayer.match.players:
                    if player.playerState == PLAYER_STATE_ALIVE:
                        if player.confirmVote == NOTCONFIRMED:
                            allConfirmed = False
                break
        if allConfirmed == True:
            alivePlayerCount = 0
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        if player.playerState == PLAYER_STATE_ALIVE:
                            alivePlayerCount += 1
            noOneToJudge = True
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        if player.voteCount *2 >= alivePlayerCount:
                            equalsToOtherPlayer = False;
                            for p in existingPlayer.match.players:
                                if p.playerId != player.playerId:
                                    if p.voteCount == player.voteCount:
                                        equalsToOtherPlayer = True;
                            if equalsToOtherPlayer == False:
                                player.beingJudged = 1
                                noOneToJudge = False
                                for p in existingPlayer.match.players:
                                    p.protocol.sendJudgePlayer(player.playerId)
                            break
                    break
            if noOneToJudge == True:
                for existingPlayer in self.players:
                    if existingPlayer.playerId == playerId:
                        for player in existingPlayer.match.players:
                            player.protocol.sendJudgePlayer("noOne")
                        break
                    
    def playerJudgementConfirmVote(self, protocol, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.confirmVote = CONFIRMED
                break
        allConfirmed = True;
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                for player in existingPlayer.match.players:
                    if player.playerState == PLAYER_STATE_ALIVE:
                        if player.confirmVote == NOTCONFIRMED:
                            if player.beingJudged == 0:
                                allConfirmed = False
                break
        if allConfirmed == True:
            alivePlayerCount = 0
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        if player.playerState == PLAYER_STATE_ALIVE:
                            if player.beingJudged == 0:
                                alivePlayerCount += 1
                    break
            guiltyVoteCount = 0
            innocentVoteCount = 0
            for existingPlayer in self.players:
                if existingPlayer.playerId == playerId:
                    for player in existingPlayer.match.players:
                        if player.judgeFor == JUDGE_GUILTY:
                            guiltyVoteCount += 1
                        if player.judgeFor == JUDGE_INNOCENT:
                            innocentVoteCount += 1
                    break
            noOneDied = True
            if guiltyVoteCount *2 >= alivePlayerCount:
                if guiltyVoteCount != innocentVoteCount:
                    noOneDied = False
                    for existingPlayer in self.players:
                        if existingPlayer.playerId == playerId:
                            for player in existingPlayer.match.players:
                                if player.beingJudged == 1:
                                    player.playerState = PLAYER_STATE_DEAD
                                    player.beingJudged = 0
                                    for player in self.players:
                                        player.protocol.sendPlayerDied(player.playerId)
                            break
            if noOneDied == True:
                for existingPlayer in self.players:
                    if existingPlayer.playerId == playerId:
                        for player in existingPlayer.match.players:
                            if player.beingJudged == 1:
                                player.beingJudged = 0                    
                            player.protocol.sendPlayerDied("noOne")
                            player.protocol.sendGameOver(NOT_OVER_YET)
                        break
            else:
                alivePlayerCount = 0
                aliveMafiaCount = 0
                for existingPlayer in self.players:
                    if existingPlayer.playerId == playerId:
                        for player in existingPlayer.match.players:
                            if player.playerState == PLAYER_STATE_ALIVE:
                                alivePlayerCount += 1
                                if player.playerTeam == PLAYER_TEAM_MAFIA:
                                    aliveMafiaCount += 1
                        break
                if aliveMafiaCount == 0:
                    for existingPlayer in self.players:
                        if existingPlayer.playerId == playerId:
                            for player in existingPlayer.match.players:
                                player.protocol.sendGameOver(CIVILIAN_WIN)
                                player.match.state = MATCH_STATE_GAME_OVER
                            break
                else:
                    if aliveMafiaCount *2 >= alivePlayerCount:
                        for existingPlayer in self.players:
                            if existingPlayer.playerId == playerId:
                                for player in existingPlayer.match.players:
                                    player.protocol.sendGameOver(MAFIA_WIN)
                                    player.match.state = MATCH_STATE_GAME_OVER
                                break
                    else:
                        for existingPlayer in self.players:
                            if existingPlayer.playerId == playerId:
                                for player in existingPlayer.match.players:
                                    player.protocol.sendGameOver(NOT_OVER_YET)
                                break
        
    def playerSendLastWords(self, protocol, lastWords, playerId):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                for player in existingPlayer.match.players:
                    player.protocol.sendPlayerHasLastWords(lastWords, playerId)
                    if player.match.state == MATCH_STATE_GAME_OVER:
                        if player.match.pendingShutdown == False:
                            player.match.pendingShutdown = True
                            player.match.shutdownTime = time() + SECS_FOR_GAMEOVER_SHUTDOWN                      
                break
                
    def startMatch(self, playerIds):
        matchPlayers = []
        for existingPlayer in self.players:
            if existingPlayer.playerId in playerIds:
                matchPlayers.append(existingPlayer)
        for player in matchPlayers:
            if player.match != None:
                return
        match = GameMatch(matchPlayers)
        teamList = []
        for teamIndex in range(3):
            for i in range(TEAM_LIST[len(matchPlayers)][teamIndex]):
                teamList.append(teamIndex)
        random.shuffle(teamList)
        index = 0
        for matchPlayer in matchPlayers:
            matchPlayer.match = match
            matchPlayer.playerState = PLAYER_STATE_ALIVE
            matchPlayer.playerTeam = teamList[index]
            matchPlayer.voteFor = 99
            index += 1
        for matchPlayer in matchPlayers:
            matchPlayer.protocol.sendMatchStarted(match)
            
    def notifyReady(self, player, inviter):
        for existingPlayer in self.players:
            if existingPlayer.playerId == inviter:
                existingPlayer.protocol.sendNotifyReady(player.playerId)    

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
        playerHeadImage = message.readString()
        playerId = message.readString()
        alias = message.readString()
        self.log("Recv MESSAGE_PLAYER_CONNECTED %s %s" % (playerId, alias))
        self.factory.playerConnected(self, playerImage, playerHeadImage, playerId, alias)

    def playerImageUpdated(self, message):
        playerImage = message.readString()
        playerHeadImage = message.readString()
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_IMAGE_UPDATED %s" % (playerId))
        self.factory.playerImageUpdated(self, playerImage, playerHeadImage, playerId)
        
    def playerAliasUpdated(self, message):
        playerAlias = message.readString()
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_ALIAS_UPDATED %s %s" % (playerAlias, playerId))
        self.factory.playerAliasUpdated(self, playerAlias, playerId)
        
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
        
    def sendUpdateJudge(self, judgeFor, judgedFor, playerId):
        message = MessageWriter()
        message.writeByte(MESSAGE_UPDATE_JUDGE)
        message.writeByte(judgeFor)
        message.writeByte(judgedFor)
        message.writeString(playerId)
        self.log("Sent MESSAGE_UPDATE_JUDGE")
        self.sendMessage(message)

    def playerVoteFor(self, message):
        voteFor = message.readByte()
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_VOTE_FOR %s %d" % (playerId, voteFor))
        self.factory.playerVoteFor(self, voteFor, playerId)
        
    def playerJudgeFor(self, message):
        judgeFor = message.readByte()
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_JUDGE_FOR %s %d" % (playerId, judgeFor))
        self.factory.playerJudgeFor(self, judgeFor, playerId)
    
    def startDiscussion(self, message):
        playerId = message.readString()
        self.log("Recv MESSAGE_START_DISCUSSION")
        self.factory.startDiscussion(self, playerId)
        
    def resetVote(self, message):
        playerId = message.readString()
        self.log("Recv MESSAGE_RESET_VOTE")
        self.factory.resetVote(self, playerId)

    def playerNightConfirmVote(self, message):
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_NIGHT_CONFIRM_VOTE %s" % (playerId))
        self.factory.playerNightConfirmVote(self, playerId)
        
    def playerDayConfirmVote(self, message):
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_DAY_CONFIRM_VOTE %s" % (playerId))
        self.factory.playerDayConfirmVote(self, playerId)

    def playerJudgementConfirmVote(self, message):
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_JUDGEMENT_CONFIRM_VOTE %s" % (playerId))
        self.factory.playerJudgementConfirmVote(self, playerId)

    def sendPlayerDied(self, playerId):
        message = MessageWriter()
        message.writeByte(MESSAGE_PLAYER_DIED)
        message.writeString(playerId)
        self.log("Sent MESSAGE_PLAYER_DIED %s" % (playerId))
        self.sendMessage(message)
        
    def sendJudgePlayer(self, playerId):
        message = MessageWriter()
        message.writeByte(MESSAGE_JUDGE_PLAYER)
        message.writeString(playerId)
        self.log("Sent MESSAGE_JUDGE_PLAYER %s" % (playerId))
        self.sendMessage(message)
        
    def sendAllowVote(self):
        message = MessageWriter()
        message.writeByte(MESSAGE_ALLOW_VOTE)
        self.log("Sent MESSAGE_ALLOW_VOTE")
        self.sendMessage(message)
        
    def playerSendLastWords(self, message):
        lastWords = message.readString()
        playerId = message.readString()
        self.log("Recv MESSAGE_PLAYER_SEND_LAST_WORDS %s" % (playerId))
        self.factory.playerSendLastWords(self, lastWords, playerId)    
        
    def sendPlayerHasLastWords(self, lastWords, playerId):
        message = MessageWriter()
        message.writeByte(MESSAGE_PLAYER_HAS_LAST_WORDS)
        message.writeString(lastWords)
        message.writeString(playerId)
        self.log("Sent MESSAGE_PLAYER_HAS_LAST_WORDS %s" % (playerId))
        self.sendMessage(message)
        
    def sendGameOver(self, whoWins):
        message = MessageWriter()
        message.writeByte(MESSAGE_GAME_OVER)
        message.writeByte(whoWins)
        self.log("Sent MESSAGE_GAME_OVER %d" % (whoWins))
        self.sendMessage(message)
        
    def sendPlayerDisconnected(self, playerId, willShutDown):
        message = MessageWriter()
        message.writeByte(MESSAGE_PLAYER_DISCONNECTED)
        message.writeByte(willShutDown)
        message.writeString(playerId)
        self.log("Sent MESSAGE_PLAYER_DISCONNECTED %s %d" % (playerId, willShutDown))
        self.sendMessage(message)
        
    def sendNotifyReady(self, playerId):
        message = MessageWriter()
        message.writeByte(MESSAGE_NOTIFY_READY)
        message.writeString(playerId)
        self.log("Sent PLAYER_NOTIFY_READY %s" % (playerId))
        self.sendMessage(message)
        
    def notifyReady(self, message):
        inviter = message.readString()
        self.log("Recv MESSAGE_NOTIFY_READY %s" % (inviter))
        self.factory.notifyReady(self.player, inviter)        
    
    def processMessage(self, message):
        messageId = message.readByte()
        if messageId == MESSAGE_PLAYER_CONNECTED:
            return self.playerConnected(message)
        if messageId == MESSAGE_START_MATCH:
            return self.startMatch(message)
        if messageId == MESSAGE_PLAYER_IMAGE_UPDATED:
            return self.playerImageUpdated(message)
        if messageId == MESSAGE_PLAYER_ALIAS_UPDATED:
            return self.playerAliasUpdated(message)
        if messageId == MESSAGE_PLAYER_SEND_CHAT:
            return self.playerSendChat(message)
        if messageId == MESSAGE_PLAYER_VOTE_FOR:
            return self.playerVoteFor(message)
        if messageId == MESSAGE_PLAYER_JUDGE_FOR:
            return self.playerJudgeFor(message)
        if messageId == MESSAGE_START_DISCUSSION:
            return self.startDiscussion(message)
        if messageId == MESSAGE_RESET_VOTE:
            return self.resetVote(message)
        if messageId == MESSAGE_PLAYER_NIGHT_CONFIRM_VOTE:
            return self.playerNightConfirmVote(message)
        if messageId == MESSAGE_PLAYER_DAY_CONFIRM_VOTE:
            return self.playerDayConfirmVote(message)
        if messageId == MESSAGE_PLAYER_JUDGEMENT_CONFIRM_VOTE:
            return self.playerJudgementConfirmVote(message)
        if messageId == MESSAGE_PLAYER_SEND_LAST_WORDS:
            return self.playerSendLastWords(message)
        if messageId == MESSAGE_NOTIFY_READY:
            return self.notifyReady(message)        
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