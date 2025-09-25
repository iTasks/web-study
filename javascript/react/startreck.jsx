import React, { useState } from 'react';
import { View, Text, Button, StyleSheet, FlatList } from 'react-native';

const storyData = {
  title: "Mission Vulcan",
  opening: "You are on a peace mission to Vulcan...",
  planets: [{
    name: "Vulcan",
    description: "A desert-like planet...",
    actions: [
      {
        command: "negotiate",
        outcome: "The negotiation was successful, peace is achieved.",
        points: 20
      },
      {
        command: "attack",
        outcome: "The attack failed, the mission is compromised.",
        points: -10
      }
    ]
  }],
  end: "Your mission is completed. Thanks for playing."
};

const App = () => {
  const [currentStage, setCurrentStage] = useState('home');
  const [outcome, setOutcome] = useState('');

  const handleAction = (action) => {
    setOutcome(action.outcome);
    setCurrentStage('end');
  };

  return (
    <View style={styles.container}>
      {currentStage === 'home' && (
        <View style={styles.content}>
          <Text style={styles.title}>{storyData.title}</Text>
          <Text>{storyData.opening}</Text>
          <Button
            title="Start Mission"
            onPress={() => setCurrentStage('game')}
          />
        </View>
      )}

      {currentStage === 'game' && (
        <View style={styles.content}>
          <Text>{storyData.planets[0].name}: {storyData.planets[0].description}</Text>
          <FlatList
            data={storyData.planets[0].actions}
            keyExtractor={(item, index) => index.toString()}
            renderItem={({ item }) => (
              <Button title={`Do ${item.command}`} onPress={() => handleAction(item)} />
            )}
          />
        </View>
      )}

      {currentStage === 'end' && (
        <View style={styles.content}>
          <Text>{outcome}</Text>
          <Text>{storyData.end}</Text>
          <Button
            title="Restart Mission"
            onPress={() => {
              setOutcome('');
              setCurrentStage('home');
            }}
          />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  content: {
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
  }
});

export default App;
