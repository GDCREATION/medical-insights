import { Component, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { NgIf } from '@angular/common';
import { AuthService, UserRole } from '../../services/auth.service';

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [RouterLink, NgIf],
  templateUrl: './landing.component.html',
  styleUrls: ['./landing.component.scss'],
})
export class LandingComponent {
  private auth = inject(AuthService);
  private router = inject(Router);

  selectRole(role: UserRole) {
    this.auth.setRole(role);
    if (role === 'patient') {
      this.router.navigateByUrl('/consent');
    } else if (role === 'clinician') {
      this.router.navigateByUrl('/clinician/review');
    } else {
      this.router.navigateByUrl('/not-authorized');
    }
  }

  currentRole() {
    return this.auth.currentRole();
  }
}

