declare module "topbar" {
  export function show(): void;
  export function hide(): void;

  interface BarColorOptions {
    [percent: number]: string;
  }
  interface ConfigOptions {
    autoRun?: boolean;
    barThickness?: number;
    barColors?: BarColorOptions;
    shadowBlur?: number;
    shadowColor?: string;
    className?: string | null;
  }

  export function config(options: ConfigOptions): void;
}
