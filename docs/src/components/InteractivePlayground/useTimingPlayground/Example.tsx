import React, { useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  WithTimingConfig,
  cancelAnimation,
} from 'react-native-reanimated';

const initialOffset = -200;

interface Props {
  options: WithTimingConfig;
}

export default function App({ options }: Props) {
  const offset = useSharedValue(initialOffset);

  const animatedStyles = useAnimatedStyle(() => {
    return {
      transform: [{ translateX: offset.value }],
    };
  });

  useEffect(() => {
    cancelAnimation(offset);
    offset.value = initialOffset;
  }, [options]);

  useEffect(() => {
    const id = setInterval(() => {
      offset.value = withTiming(-initialOffset, options, (isFinished) => {
        setTimeout(() => {
          if (isFinished) {
            offset.value = initialOffset;
          }
        }, options.duration);
      });
    }, options.duration);

    return () => clearInterval(id);
  }, [options]);

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.box, animatedStyles]} />
      <View style={[styles.box, styles.ghost]} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
  },
  box: {
    height: 100,
    width: 100,
    backgroundColor: '#b58df1',
    borderRadius: 20,
    marginVertical: 64,
  },
  ghost: {
    opacity: 0.3,
    position: 'absolute',
    transform: [{ translateX: initialOffset }],
  },
});
