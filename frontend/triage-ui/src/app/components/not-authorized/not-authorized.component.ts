import { Component, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { NgIf } from '@angular/common';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-not-authorized',
  standalone: true,
  imports: [RouterLink, NgIf],
  templateUrl: './not-authorized.component.html',
  styleUrls: ['./not-authorized.component.scss', '../../shared/styles.scss'],
})
export class NotAuthorizedComponent {
  private router = inject(Router);
  auth = inject(AuthService);

  goHome() {
    this.router.navigateByUrl('/');
  }

  isAuthenticated() {
    return this.auth.isAuthenticated();
  }

  logout() {
    this.auth.logout();
  }
}
