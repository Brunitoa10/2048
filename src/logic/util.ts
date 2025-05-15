export function numberToColor(num: number) {
    switch (num) {
        case 2: return "#a3b1c6";
        case 4: return "#a3f2b0";
        case 8: return "#7ee887";
        case 16: return "#4fd471";
        case 32: return "#28b463";
        case 64: return "#1e8449";
        case 128: return "#145a32";
        case 256: return "#fca5a5";
        case 512: return "#f87171";
        case 1024: return "#ef4444";
        case 2048: return "#dc2626";
        case 4096: return "#b91c1c";
        case 8192: return "#7f1d1d";
        case 16384: return "#450a0a";
        default: return "black";
    }
    
    
}

export function delay(milliseconds: number) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
}