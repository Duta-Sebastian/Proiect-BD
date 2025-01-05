import React from 'react';
import Link from 'next/link';
import './TopMenu.css';

const TopMenu = () => {
  return (
    <div className="top-menu">
      <Link href="/">
          <button className="menu-button">Home</button>
      </Link>
      <Link href="/LMD-Tables">
        <button className="menu-button">LMD pe tabele</button>
      </Link>
      <Link href="/cereri">
        <button className="menu-button">Cereri</button>
      </Link>
      <Link href="/section3">
        <button className="menu-button">Views</button>
      </Link>
    </div>
  );
};

export default TopMenu;
