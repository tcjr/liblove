import type Owner from '@ember/owner';
import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import {
  AUTH_EVENTS,
  getUser,
  handleAuthCallback,
  login,
  logout,
  onAuthChange,
  signup,
  type SignupData,
  type User,
} from '@netlify/identity';

export default class AuthService extends Service {
  @tracked user: User | null = null;
  @tracked loading = true;

  initialize = async () => {
    console.log('[service/auth] Initializing auth service...');
    try {
      console.log('[service/auth] awaiting handleAuthCallback()...');
      await handleAuthCallback();
      console.log('[service/auth] Calling getUser()...');
      this.user = await getUser();
      console.log('[service/auth] User:', this.user);
    } catch (error) {
      console.error('[service/auth] Auth initialization failed:', error);
    } finally {
      this.loading = false;
    }

    onAuthChange((event, currentUser) => {
      console.log('[service/auth] onAuthChange', event, currentUser);
      switch (event) {
        case AUTH_EVENTS.LOGIN:
          console.log('[service/auth] Logged in:', currentUser?.email);
          break;
        case AUTH_EVENTS.LOGOUT:
          console.log('[service/auth] Logged out');
          break;
        case AUTH_EVENTS.TOKEN_REFRESH:
          console.log('[service/auth] TOKEN_REFRESH');
          break;
        case AUTH_EVENTS.USER_UPDATED:
          console.log('[service/auth] Profile updated:', currentUser?.email);
          break;
        case AUTH_EVENTS.RECOVERY:
          console.log('[service/auth] Password recovery initiated');
          break;
      }
      this.user = currentUser;
    });
  };

  get isAuthenticated() {
    return !!this.user;
  }

  login = async (email: string, password: string) => {
    return await login(email, password);
  };

  signup = async (email: string, password: string, data?: SignupData) => {
    return await signup(email, password, data);
  };

  logout = async () => {
    await logout();
    this.user = null;
  };
}
