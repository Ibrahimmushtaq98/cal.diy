"use client";

import { createContext, useContext, useRef, type ReactNode } from "react";
import { useStoreWithEqualityFn } from "zustand/traditional";
import type { StoreApi } from "zustand";

import { createBookingActionsStore, type BookingActionsStore } from "./store";

export const BookingActionsStoreContext = createContext<StoreApi<BookingActionsStore> | null>(null);

export interface BookingActionsStoreProviderProps {
  children: ReactNode;
}

export const BookingActionsStoreProvider = ({ children }: BookingActionsStoreProviderProps) => {
  const storeRef = useRef<StoreApi<BookingActionsStore>>(undefined);
  if (!storeRef.current) {
    storeRef.current = createBookingActionsStore();
  }

  return (
    <BookingActionsStoreContext.Provider value={storeRef.current}>
      {children}
    </BookingActionsStoreContext.Provider>
  );
};

export const useBookingActionsStoreContext = <T,>(
  selector: (store: BookingActionsStore) => T,
  equalityFn?: (a: T, b: T) => boolean
): T => {
  const bookingActionsStoreContext = useContext(BookingActionsStoreContext);

  if (!bookingActionsStoreContext) {
    throw new Error("useBookingActionsStoreContext must be used within BookingActionsStoreProvider");
  }

  return useStoreWithEqualityFn(bookingActionsStoreContext, selector, equalityFn);
};
