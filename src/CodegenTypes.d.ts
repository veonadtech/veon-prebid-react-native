/**
 * Local type definitions for React Native Codegen types
 * This file provides type definitions when react-native/Libraries/Types/CodegenTypes is not available
 */

declare module 'react-native/Libraries/Types/CodegenTypes' {
  /**
   * Int32 type for codegen
   */
  export type Int32 = number;

  /**
   * Direct event handler type for codegen
   */
  export type DirectEventHandler<T> = (event: { nativeEvent: T }) => void;
}
