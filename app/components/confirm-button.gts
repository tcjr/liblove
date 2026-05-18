import { on } from '@ember/modifier';
import Component from '@glimmer/component';
import { Modal } from 'ember-primitives';

interface ConfirmButtonSignature {
  Args: {
    title: string;
    confirmText: string;
    buttonText: string;
    onConfirm: () => void | Promise<void>;
    message?: string;
  };
  Blocks: {
    default?: [];
  };
  Element: HTMLButtonElement;
}

/**
 * Usage Examples:
 *
 * Simple case with message string:
 *
 * <ConfirmButton
 *   @title="Close Claiming"
 *   @message="This will close the squares claiming and lock the pool. Are you sure?"
 *   @confirmText="Yes, close claiming"
 *   @buttonText="Close Claiming"
 *   @onConfirm={{this.closeClaimingAction}}
 *   class="btn btn-warning"
 *   disabled={{this.isProcessing}}
 * />
 *
 * Complex case with block content:
 *
 * <ConfirmButton
 *   @title="Delete Contest"
 *   @confirmText="Yes, delete forever"
 *   @buttonText="Delete Contest"
 *   @onConfirm={{this.deleteContest}}
 *   class="btn btn-error"
 *   data-testid="delete-button"
 * >
 *   <div class="space-y-3">
 *     <p>This will permanently delete the contest <strong>{{this.contest.title}}</strong>.</p>
 *     <div class="alert alert-error">
 *       <strong>⚠️ Warning:</strong> This action cannot be undone!
 *     </div>
 *     <p>All squares, payments, and history will be lost.</p>
 *   </div>
 * </ConfirmButton>
 */
export default class ConfirmButton extends Component<ConfirmButtonSignature> {
  onModalClosed = async (modalResponse: string) => {
    if (modalResponse === 'YES') {
      await this.args.onConfirm();
    }
  };

  <template>
    <Modal @onClose={{this.onModalClosed}} as |m|>
      <m.Dialog class="modal">
        <div class="modal-box">
          <form method="dialog">
            <button
              type="submit"
              value=""
              class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
            >✕</button>

            <h3 class="text-lg font-bold">{{@title}}</h3>

            {{#if (has-block)}}
              {{yield}}
            {{else}}
              <p class="py-4">{{@message}}</p>
            {{/if}}

            <div class="modal-action">
              <button class="btn btn-primary" type="submit" value="YES">
                {{@confirmText}}
              </button>
              <button class="btn" type="submit" value="">
                Cancel
              </button>
            </div>
          </form>
        </div>
      </m.Dialog>
      <button type="button" {{on "click" m.open}} ...attributes>
        {{@buttonText}}
      </button>
    </Modal>
  </template>
}
