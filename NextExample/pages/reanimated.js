import Animated from 'react-native-reanimated'
import { StyleSheet } from 'react-native'

export default function Reanimated() {
  return (
    <Animated.View style={styles.container}>
      <Animated.Text accessibilityRole="header" style={styles.text}>
        Reanimated Page
      </Animated.Text>
      <Animated.Text style={styles.link} accessibilityRole="link" href={`/`}>
        Go Back
      </Animated.Text>
    </Animated.View>
  )
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    flexGrow: 1,
    justifyContent: 'center',
  },
  text: {
    alignItems: 'center',
    fontSize: 24,
    marginBottom: 24,
  },
  link: {
    color: 'blue',
  },
})