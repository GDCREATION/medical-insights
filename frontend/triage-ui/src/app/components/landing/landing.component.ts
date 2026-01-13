import { Component, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { NgIf, TitleCasePipe } from '@angular/common';
import { AuthService, UserRole } from '../../services/auth.service';

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [NgIf, TitleCasePipe],
  templateUrl: './landing.component.html',
  styleUrls: ['./landing.component.scss'],
})
export class LandingComponent {
  auth = inject(AuthService);
  private router = inject(Router);
  
  showUserMenu = signal(false);

  loginAs(role: UserRole) {
    this.auth.login(role);
  }

  logout(event?: Event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    this.showUserMenu.set(false);
    // Small delay to ensure menu closes before logout redirect
    setTimeout(() => {
      this.auth.logout();
    }, 100);
  }

  currentRole() {
    return this.auth.currentRole();
  }

  getUserInitials(): string {
    const user = this.auth.user();
    if (!user) return '?';
    
    const name = user.name || user.email || '';
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  getUserEmail(): string {
    return this.auth.user()?.email || 'No email';
  }

  getUserName(): string {
    const user = this.auth.user();
    return user?.name || user?.email || 'User';
  }

  toggleUserMenu() {
    this.showUserMenu.update(v => !v);
  }

  closeUserMenu() {
    this.showUserMenu.set(false);
  }

  handleMenuFocusOut(event: FocusEvent) {
    // Don't close menu if focus is moving to an element inside the dropdown
    const relatedTarget = event.relatedTarget as HTMLElement;
    if (relatedTarget && relatedTarget.closest('.user-menu-dropdown')) {
      return;
    }
    // Small delay to allow click events to register
    setTimeout(() => {
      this.closeUserMenu();
    }, 150);
  }

  getRoleIcon(): string {
    const role = this.currentRole();
    switch (role) {
      case 'patient': return '👤';
      case 'clinician': return '🩺';
      case 'admin': return '⚙️';
      default: return '👤';
    }
  }

  goToConsent() {
    this.router.navigateByUrl('/consent');
  }

  goToReview() {
    this.router.navigateByUrl('/clinician/review');
  }
}
