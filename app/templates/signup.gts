import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import type AuthService from '#app/services/auth';
import { dataFromEvent } from 'ember-primitives/components/form';

export default class SignupComponent extends Component {
  @service auth!: AuthService;

  @tracked email = '';
  @tracked password = '';
  @tracked name = '';
  @tracked error = '';
  @tracked success = false;
  @tracked loading = false;

  handleSubmit = async (event: Event) => {
    event.preventDefault();
    this.error = '';
    this.loading = true;

    const formData = dataFromEvent(event);
    this.email = String(formData.email);
    this.password = String(formData.password);
    this.name = String(formData.name);

    try {
      console.log('[signup] calling this.auth.signup...');
      const user = await this.auth.signup(this.email, this.password, {
        full_name: this.name,
      });
      console.log('[signup] user', user);

      // if (user.confirmedAt) {
      //   this.success = true; // Auto-confirmed
      // } else {
      //   this.success = true; // Needs confirmation
      // }
    } catch (e) {
      console.error(e);
      this.error = 'Signup failed';
    } finally {
      this.loading = false;
    }
  };

  <template>
    <div class="max-w-md mx-auto card bg-base-100 shadow-xl mt-8">
      <div class="card-body">
        <h2 class="card-title justify-center text-2xl mb-4">Sign Up</h2>

        {{!-- {{#if this.success}}
          <div class="alert alert-success">
            <span>Check your email to confirm your account and start using Lib Love!</span>
          </div>
        {{else}} --}}
        <form {{on "submit" this.handleSubmit}} class="flex flex-col gap-4">
          <label class="form-control w-full">
            <div class="label">
              <span class="label-text">Full Name</span>
            </div>
            <input
              type="text"
              placeholder="Jane Doe"
              class="input input-bordered w-full"
              required
              name="name"
              {{!on "input" (fn (mut this.name) value="target.value")}}
            />
          </label>

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
              Create Account
            </button>
          </div>
        </form>
        {{!-- {{/if}} --}}
      </div>
    </div>
  </template>
}
