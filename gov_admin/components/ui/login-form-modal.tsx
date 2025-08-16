import LoginPage from "@/app/auth/login/page";

export default function LoginFormModal({ onClose }: { onClose: () => void }) {
  return <LoginPage isModal onClose={onClose} />;
}
