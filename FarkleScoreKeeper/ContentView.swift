//
//  ContentView.swift
//  FarkleScoreKeeper
//
//  Created by MJ Orton on 8/6/23.
//
import SwiftUI

struct ContentView: View {
    @State private var playerName = ""
    @State private var isAddingPlayers = false
    @State private var isGameStarted = false
    @State private var selectedPlayerIndex: Int? = nil
    @State private var isScoreEntryViewPresented = false
    @State private var playersInfo: [PlayerInfo] = []
    @State private var gameWinner: String? = nil
    @State private var showGameWinnerAlert = false
    @State private var showEnterScoreAlert = false
    @State private var score = ""
    @FocusState var isInputActive: Bool
    @State private var editMode: EditMode = .inactive

   
    struct PlayerInfo: Equatable {
        var name: String
        var score: Int
    }
    
    var playerScore: Int = 0
    
    var selectedPlayerName: String? {
        if let selectedPlayerIndex = selectedPlayerIndex {
            return playersInfo[selectedPlayerIndex].name
        }
        return nil
    }
    
    var selectedPlayerScore: Int {
        if let selectedPlayer = selectedPlayerName {
            return playersInfo.first { $0.name == selectedPlayer }?.score ?? 0
        }
        return 0
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(1)]), // You can adjust the opacity and add more colors if needed
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all) // Extend the gradient to the edges of the view
//            NavigationView {
                VStack {
                    Spacer()
                    Text("Farkle Score Keeper")
                        .font(.title)
                        .bold()
                    Spacer()
                    NavigationView {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), // You can adjust the opacity and add more colors if needed
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .edgesIgnoringSafeArea(.all) // Extend the gradient to the edges of the view
                        VStack {
                            if !isGameStarted {
                                HStack {
                                    TextField("Enter player name", text: $playerName, onCommit: {
                                        if !playerName.isEmpty {
                                            playersInfo.append(PlayerInfo(name: playerName, score: 0))
                                            DispatchQueue.main.async {
                                                self.playerName = ""
                                            }
                                        }
                                    })
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            HStack {
                                                Spacer()
                                                
                                                Button("Done") {
                                                    isInputActive = false
                                                }
                                            }
                                        }
                                    }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                    .focused($isInputActive)
                                    
                                    Button("Add") {
                                        if !playerName.isEmpty {
                                            playersInfo.append(PlayerInfo(name: playerName, score: 0))
                                            playerName = ""
                                        }
                                    }
                                    .foregroundColor(Color.yellow)
                                    .opacity(playerName.isEmpty ? 0.5 : 1.0)
                                    .disabled(playerName.isEmpty)
                                    .font(.title2.bold())
                                    .padding(.trailing) // Add padding to the trailing edge of the button
                                }
                                Spacer()
                            }
                            
                            if isGameStarted || !playersInfo.isEmpty {
                                ZStack {
                                    List {
                                        ForEach(playersInfo, id: \.name) { playerInfo in
                                            Button(action: {
                                                selectedPlayerIndex = playersInfo.firstIndex(of: playerInfo)
                                                showEnterScoreAlert = true
                                            }) {
                                                HStack {
                                                    Text(playerInfo.name)
                                                    Spacer()
                                                    Text("Current Score: \(playerInfo.score.formatted())")
                                                }
                                                    .foregroundColor(.black)
                                            }
                                            .listRowBackground(Color.yellow)
                                        }
                                        .onDelete(perform: deletePlayer)
                                        .deleteDisabled(isGameStarted)
                                        .environment(\.editMode, isGameStarted ? .constant(.inactive) : .constant(.active)) // Disable delete when game is started
//                                        .environment(\.editMode, $editMode) SWITCHING FROM                                                                             LIGHT AND DARK MODE
                                        .disabled(!isGameStarted)
                                    }
                                    .scrollContentBackground(.hidden)
                                }
                                
                            }
                            
                            if !isGameStarted {
                                Button("Start Game") {
                                    isGameStarted = true
                                }
                                .foregroundColor(.yellow)
                                .font(.title.bold())
                                .disabled(playersInfo.isEmpty)
                                .opacity(playersInfo.isEmpty ? 0.5 : 1.0)
                            }  else {
                                HStack {
                                    Button("Restart Game") {
                                        restartGame()
                                    }
                                    .foregroundColor(.yellow)
                                    .font(.title.bold())
                                }
                            }
                            
                        }
                        .navigationTitle("Player List")
                        .navigationBarItems(trailing: EditButton())
                        .alert(isPresented: $showGameWinnerAlert) {
                            Alert(
                                title: Text("Congrats \(playersInfo[selectedPlayerIndex!].name) Wins!!🥳"),
                                message: Text("With a total score of \(selectedPlayerScore) points!"),
                                primaryButton: .default(Text("Continue")) {
                                    // Add any code here to continue the game
                                    // You can leave it empty if you just want to dismiss the alert
                                },
                                secondaryButton: .default(Text("Restart Game")) {
                                    restartGame()
                                }
                            )
                        }

                        .alert(alertTitle(), isPresented: $showEnterScoreAlert, actions: {
                            TextField("Enter Your Score", text: $score)
                                .keyboardType(.numberPad)
                            Button("Cancel", action: { }) //role: .desctructive
                            Button("Save", action: save)
                        }, message: {
                            Text("Current Score: \(selectedPlayerScore)")
                        })
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    
                    Button("Done") {
                        isInputActive = false
                    }
                }
            }
        }
    }
    
    func deletePlayer(at offsets: IndexSet) {
        if !isGameStarted {
                playersInfo.remove(atOffsets: offsets)
            }
    }
    
    func alertTitle() -> String {
        if let selectedPlayerIndex {
            return "Enter Score for \(playersInfo[selectedPlayerIndex].name)"
        } else {
            return "No player selected"
        }
    }
    
    func save() {
        guard let intScore = Int(score) else { return }
        guard let selectedPlayerIndex else { return }
        updatePlayerScore(selectedPlayerIndex: selectedPlayerIndex, newScore: intScore)
        score = ""
    }
    
    func cancel() {
        score = ""
    }
    
    func restartGame() {
        playersInfo.removeAll()
        playerName = ""
        isGameStarted = false
        selectedPlayerIndex = nil
        isScoreEntryViewPresented = false
        playersInfo.removeAll()
        gameWinner = nil
    }
    
    func continueGame() {
        
    }
    
    func updatePlayerScore(selectedPlayerIndex: Int, newScore: Int) {
        
            playersInfo[selectedPlayerIndex].score += newScore
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                // Check if the player has reached 10,000 points
                if playersInfo[selectedPlayerIndex].score >= 10000 {
                    gameWinner = playerName
                    showGameWinnerAlert = true
                }
            }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
