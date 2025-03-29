import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { useEffect, useMemo, useRef } from 'react';
import { Mesh, PlaneGeometry, Vector2 } from 'three';
import fragmentShader from './shaders/fragment.glsl';
import vertexShader from './shaders/vertex.glsl';

const FullScreenQuad = () => {
  const mesh = useRef<Mesh<PlaneGeometry>>(null);
  const { viewport } = useThree();

  // Create uniforms with screen size and mouse position
  const uniforms = useMemo(() => {
    return {
      u_time: { value: 0.0 },
      u_resolution: { value: new Vector2() },
      u_mouse: { value: new Vector2(-1, 1) }, // Add mouse uniform
      u_dotSize: { value: 15.0 },
      u_dotSpacing: { value: 45.0 },
      u_bounceAmount: { value: 10.0 },
      u_bounceSpeed: { value: 2.0 },
      u_waveFrequency: { value: 0.2 },
    };
  }, []);

  // Update time uniform on each frame
  useFrame(({ clock }) => {
    uniforms.u_time.value = clock.elapsedTime;
  });

  // Update resolution when viewport changes
  useEffect(() => {
    uniforms.u_resolution.value.set(viewport.width, viewport.height);
  }, [viewport, uniforms]);

  // Update mouse position
  useEffect(() => {
    const handleMouseMove = (event: MouseEvent) => {
      const x = (event.clientX / window.innerWidth) * 2 - 1; // Normalize to [-1, 1]
      const y = -(event.clientY / window.innerHeight) * 2 + 1; // Normalize to [-1, 1]
      uniforms.u_mouse.value.set(x, y);
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, [uniforms]);

  return (
    <mesh
      ref={mesh}
      scale={[viewport.width, viewport.height, 1]}
      position={[0, 0, 0]}
    >
      <planeGeometry args={[1, 1]} />
      <shaderMaterial
        uniforms={uniforms}
        fragmentShader={fragmentShader}
        vertexShader={vertexShader}
        transparent={true}
      />
    </mesh>
  );
};

const Scene = () => {
  return (
    <Canvas
      orthographic
      camera={{
        position: [0, 0, 1],
        near: 0.1,
        far: 1000,
        zoom: 1,
      }}
      style={{ width: '100vw', height: '100vh' }}
    >
      <FullScreenQuad />
    </Canvas>
  );
};

export default Scene;
