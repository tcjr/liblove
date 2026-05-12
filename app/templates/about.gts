import Component from '@glimmer/component';
import type AuthService from '#app/services/auth.ts';
import { service } from '@ember/service';
import { pageTitle } from 'ember-page-title';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';

export default class About extends Component {
  @service declare auth: AuthService;

  <template>
    {{pageTitle "About"}}
    <div>
      <h1 class="font-bold text-3xl">About</h1>

      {{#if this.auth.isAuthenticated}}
        <div class="alert alert-success">
          You are logged in.
        </div>
        <div>
          <button
            class="btn btn-sm"
            {{on "click" this.auth.logout}}
            type="button"
          >
            Logout
          </button>
        </div>
      {{else}}
        <div class="alert alert-warning">
          You are not logged in.
        </div>
        <div class="flex w-full">
          <div>
            <button
              class="btn btn-sm"
              {{on
                "click"
                (fn this.auth.login "fakeuser@tcjr.org" "FAKEPASSWORD")
              }}
              type="button"
            >
              Login (fake user)
            </button>
          </div>
          <div class="divider divider-horizontal">OR</div>
          <div>
            <button
              class="btn btn-sm"
              {{on
                "click"
                (fn
                  this.auth.signup "fakeuser@tcjr.org" "FAKEPASSWORD" undefined
                )
              }}
              type="button"
            >
              Sign Up (fake user)
            </button>

          </div>
        </div>
      {{/if}}

    </div>
  </template>
}
