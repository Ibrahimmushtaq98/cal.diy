import type { Mock } from "vitest";
import { beforeEach, vi } from "vitest";
import { mockClear, mockDeep } from "vitest-mock-extended";

import type * as OAuthManager from "../../_utils/oauth/OAuthManager";

vi.mock("../../_utils/oauth/OAuthManager", () => oAuthManagerMock);
let useFullMockOAuthManagerRequest: boolean | null = null;

beforeEach(() => {
  mockClear(oAuthManagerMock);
  useFullMockOAuthManagerRequest = null;
});

const oAuthManagerRequestFullMock = async (fn: () => Promise<Response>) => {
  const res = await fn();
  return {
    json: await res.json(),
  };
};

const oAuthManagerMock = mockDeep<typeof OAuthManager>({
  fallbackMockImplementation: () => {
    throw new Error("Unimplemented");
  },
});

export default oAuthManagerMock;
const setFullMockOAuthManagerRequest = () => {
  useFullMockOAuthManagerRequest = true;
};
// Typed explicitly so the declaration doesn't point into vitest's internal chunk files.
const defaultMockOAuthManager: Mock = vi.fn().mockImplementation(function() {
  return {
    getTokenObjectOrFetch: vi.fn().mockImplementation(function() {
      return {
        token: {
          access_token: "FAKE_ACCESS_TOKEN",
        },
      };
    }),
    request: vi.fn().mockImplementation(function(fn) {
      if (useFullMockOAuthManagerRequest) {
        console.log("OAuthManager.request full mock being used");
        return oAuthManagerRequestFullMock(fn);
      }
      console.log("OAuthManager.request default mock being used");
      return {
        json: {
          calendars: [],
        },
      };
    }),
  };
});

export { oAuthManagerMock, defaultMockOAuthManager, setFullMockOAuthManagerRequest };
