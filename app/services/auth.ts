import type Owner from '@ember/owner';
import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import {
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

  constructor(owner: Owner) {
    super(owner);
    void this.initialize();
  }

  // TODO: consider moving the call to initialize to the application or application route

  private async initialize() {
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

    onAuthChange((_event, currentUser) => {
      this.user = currentUser;
    });
  }

  get isAuthenticated() {
    return !!this.user;
  }

  async login(email: string, password: string) {
    return await login(email, password);
  }

  async signup(email: string, password: string, data?: SignupData) {
    return await signup(email, password, data);
  }

  async logout() {
    await logout();
    this.user = null;
  }
}
