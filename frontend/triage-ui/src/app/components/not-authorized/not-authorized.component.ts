import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-not-authorized',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section class="card">
      <h2>Access restricted</h2>
      <p>You do not have access to this area. Please select a role.</p>
      <a routerLink="/" class="link">Return to landing</a>
    </section>
  `,
  styles: [
    `
      .card {
        max-width: 600px;
        margin: 1.5rem auto;
        padding: 1.5rem;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        background: #fff;
      }
      .link {
        color: #0f766e;
      }
    `,
  ],
})
export class NotAuthorizedComponent {}

