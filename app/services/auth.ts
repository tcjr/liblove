import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import {
  getUser,
  handleAuthCallback,
  onAuthChange,
  type User as NetlifyUser,
  type AuthEvent,
  AUTH_EVENTS,
  logout,
  login,
  signup,
  type SignupData,
} from '@netlify/identity';

export default class AuthService extends Service {
  @tracked authUser: NetlifyUser | null = null;

  initialize = async () => {
    console.log('[service/auth] Initializing auth service...');
    try {
      await handleAuthCallback();
    } catch (error) {
      // This means the callback token is invalid or the verification request failed. I'm not sure
      // how to handle this yet.
      console.error('[service/auth] Error handling auth callback:', error);
      throw error;
    }

    // If there is a user in session already (however Netlify identity defines it), then `getUser`
    // will return it. If not, it will return null.  It won't throw.
    console.log('[service/auth] getting auth user...');
    this.authUser = await getUser();
    console.log('[service/auth] Auth user:', this.authUser);

    console.log('[service/auth] setting up auth callback...');
    onAuthChange((event: AuthEvent, user: NetlifyUser | null) => {
      console.group(
        '[service/auth](onAuthChange) event:',
        event,
        'user:',
        user
      );
      switch (event) {
        case AUTH_EVENTS.LOGIN:
          console.log('(AUTH_EVENTS.LOGIN) Logged in:', user?.email);
          console.log('Setting service authUser to:', user);
          this.authUser = user;
          break;
        case AUTH_EVENTS.LOGOUT:
          console.log('(AUTH_EVENTS.LOGOUT) Logged out');
          console.log('Setting service authUser to:', user);
          this.authUser = user;
          break;
        case AUTH_EVENTS.TOKEN_REFRESH:
          console.log('(AUTH_EVENTS.TOKEN_REFRESH) TOKEN_REFRESH');
          break;
        case AUTH_EVENTS.USER_UPDATED:
          console.log(
            '(AUTH_EVENTS.USER_UPDATED) Profile updated:',
            user?.email
          );
          console.log('NOT IMPLEMENTED');
          break;
        case AUTH_EVENTS.RECOVERY:
          console.log('(AUTH_EVENTS.RECOVERY) Password recovery initiated');
          console.log('NOT IMPLEMENTED');
          break;
        default:
          console.log('(UNKNOWN EVENT)');
          console.log('NOT IMPLEMENTED');
          break;
      }

      console.groupEnd();
    });

    console.log('[service/auth] initialized');
  };

  get isAuthenticated() {
    return !!this.authUser;
  }

  login = async (email: string, password: string) => {
    console.log('[service/auth] login called');
    return await login(email, password);
  };

  logout = async () => {
    console.log('[service/auth] logout called');
    // calling this should trigger an event to be handled by onAuthChange()
    await logout();
  };

  signup = async (email: string, password: string, data?: SignupData) => {
    console.log('[service/auth] signup called');
    return await signup(email, password, data);
  };
}
