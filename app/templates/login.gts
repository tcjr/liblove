import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import type RouterService from '@ember/routing/router-service';
import type AuthService from '#app/services/auth';
import { dataFromEvent } from 'ember-primitives/components/form';

export default class LoginComponent extends Component {
  @service auth!: AuthService;
  @service router!: RouterService;

  @tracked email = '';
  @tracked password = '';
  @tracked error = '';
  @tracked loading = false;

  handleSubmit = async (event: Event) => {
    event.preventDefault();
    this.error = '';
    this.loading = true;

    const formData = dataFromEvent(event);
    this.email = String(formData.email);
    this.password = String(formData.password);

    try {
      console.log('[login] calling this.auth.login...');
      await this.auth.login(this.email, this.password);
      console.log('[login] logged in, redirecting');
      this.router.transitionTo('index');
    } catch (e) {
      console.error(e);
      this.error = 'Login failed';
    } finally {
      this.loading = false;
    }
  };

  <template>
    <div class="max-w-md mx-auto card bg-base-100 shadow-xl mt-8">
      <div class="card-body">
        <h2 class="card-title justify-center text-2xl mb-4">Login</h2>

        <form {{on "submit" this.handleSubmit}} class="flex flex-col gap-4">
          <label class="form-control w-full">
            <div class="label">
              <span class="label-text">Email</span>
            </div>
            <input
              type="email"
              placeholder="you@example.com"
              class="input input-bordered w-full"
              required
              name="email"
              {{!on "input" (fn (mut this.email) value="target.value")}}
            />
          </label>

          <label class="form-control w-full">
            <div class="label">
              <span class="label-text">Password</span>
            </div>
            <input
              type="password"
              class="input input-bordered w-full"
              required
              name="password"
              {{!on "input" (fn (mut this.password) value="target.value")}}
            />
          </label>

          {{#if this.error}}
            <div class="alert alert-error text-sm">
              <span>{{this.error}}</span>
            </div>
          {{/if}}

          <div class="card-actions justify-end mt-4">
            <button
              class="btn btn-primary w-full"
              type="submit"
              disabled={{this.loading}}
            >
              {{#if this.loading}}
                <span class="loading loading-spinner"></span>
              {{/if}}
              Login
            </button>
          </div>
        </form>
      </div>
    </div>
  </template>
}
